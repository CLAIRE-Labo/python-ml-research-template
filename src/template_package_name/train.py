import logging
import os
import subprocess
import sys
from pathlib import Path
from time import sleep

import hydra
import wandb
from omegaconf import DictConfig, OmegaConf, omegaconf

from template_package_name import utils

utils.config.register_resolvers()
logger = logging.getLogger(__name__)


@hydra.main(version_base=None, config_path="configs", config_name="template_experiment")
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
