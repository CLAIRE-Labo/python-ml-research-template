import logging
import os
import subprocess
import sys
from pathlib import Path

import hydra
import torch
import wandb
from datasets import load_dataset
from omegaconf import DictConfig, OmegaConf, omegaconf
from transformers import AutoTokenizer
from trl import SFTConfig, SFTTrainer

from template_package_name import utils

utils.config.register_resolvers()
logger = logging.getLogger(__name__)


@hydra.main(version_base=None, config_path="configs", config_name="train")
def main(config: DictConfig) -> None:
    logger.info(f"Init directory: {Path.cwd()}")
    resuming_dir, resuming_hash = utils.config.setup_resuming_dir(config)
    logger.info(f"Run can be resumed from the directory: {resuming_dir}")
    if config.resuming.resume:
        os.chdir(resuming_dir)
        logger.info(f"Resuming from the directory: {Path.cwd()}")

    postprocess_and_save_config(config)

    wandb_run_id = config.wandb.run_id
    if wandb_run_id is None:
        if config.resuming.resume:
            wandb_run_id = resuming_hash
    wandb.init(
        id=wandb_run_id,
        resume="allow" if config.resuming.resume else "never",
        config=OmegaConf.to_container(config),
        project=config.wandb.project,
        tags=config.wandb.tags,
        mode=config.wandb.mode,
        anonymous=config.wandb.anonymous,
        dir=Path(config.wandb.dir).absolute(),
    )

    # Re-log to capture log with wandb.
    logger.info(f"Running command: {subprocess.list2cmdline(sys.argv)}")
    logger.info(f"Init directory: {config.run_dir}")
    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Running with config: \n{OmegaConf.to_yaml(config)}")
    if config.resuming.resume:
        logger.info(f"Resuming from the directory: {Path.cwd()}")

    utils.seeding.seed_everything(config)

    # Your code here
    model_kwargs = dict(
        trust_remote_code=True,
        torch_dtype=torch.float16,
        use_cache=not config.gradient_checkpointing,
    )
    tokenizer = AutoTokenizer.from_pretrained(
        config.model_name_or_path,
        trust_remote_code=True,
        use_fast=True,
    )
    tokenizer.pad_token = tokenizer.eos_token

    ################
    # Dataset
    ################
    dataset = load_dataset(config.dataset_name)

    sft_config = SFTConfig(
        packing=config.packing,
        learning_rate=config.learning_rate,
        num_train_epochs=config.num_train_epochs,
        per_device_train_batch_size=config.per_device_train_batch_size,
        gradient_accumulation_steps=config.gradient_accumulation_steps,
        gradient_checkpointing=config.gradient_checkpointing,
        logging_steps=config.logging_steps,
        eval_strategy=config.eval_strategy,
        eval_steps=config.eval_steps,
        output_dir=resuming_dir,
        seed=config.seed,
        max_seq_length=config.max_seq_length,
        remove_unused_columns=False,
        per_device_eval_batch_size=config.per_device_train_batch_size,
        report_to=config.report_to,
        logging_first_step=True,
        eval_on_start=config.eval_on_start,
        save_strategy="steps",
        save_steps=config.save_steps,
        model_init_kwargs=model_kwargs,
    )

    trainer = SFTTrainer(
        model=config.model_name_or_path,
        args=sft_config,
        train_dataset=dataset["train"],
        eval_dataset=dataset["test"] if config.eval_strategy != "no" else None,
        processing_class=tokenizer,
    )

    # Train and save the model.
    resume_from_checkpoint = (
        config.resuming.resume
        and len([item for item in Path(config.resuming_dir).iterdir() if item.is_dir()])
        > 1  # counting the config dir.
    )
    trainer.train(resume_from_checkpoint=resume_from_checkpoint)
    trainer.save_model(resuming_dir)


def postprocess_and_save_config(config):
    """Here you can make some computations with the config to add new keys, correct some values, etc.
    E.g., read-only variables that can be useful when navigating the experiments on wandb
     for filtering, sorting, etc.
    Save the new config (as a file to record it) and pass it to wandb to record it with your experiment.
    """
    Path("config/").mkdir(exist_ok=True)
    # Save if it doesn't exist otherwise (in case of resuming) assert that the config is the same.
    utils.config.maybe_save_config(config, "config/config-before-postprocess.yaml")
    with omegaconf.open_dict(config):
        # Example of adding a new key to the config
        config.some_new_key = "bar"
    OmegaConf.resolve(config)
    utils.config.maybe_save_config(config, "config/config-resolved.yaml")


if __name__ == "__main__":
    main()
