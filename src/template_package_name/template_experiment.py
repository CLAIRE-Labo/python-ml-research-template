"""An example file to run an experiment.
Keep this, it's used as an example to run the code after a user installs the project.
"""

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

# Refers to utils for a description of resolvers
utils.config.register_resolvers()

# Hydra sets up the logger automatically.
# https://hydra.cc/docs/tutorials/basic/running_your_app/logging/
logger = logging.getLogger(__name__)


@hydra.main(version_base=None, config_path="configs", config_name="template_experiment")
def main(config: DictConfig) -> None:
    # The current working directory is a new directory unique to this run made by hydra, accessible by config.run_dir.
    # A resuming directory uniquely identified by the config (and optionally the git sha)
    # for storing checkpoints of the same experiment can be accessed via config.resuming.dir.
    logger.info(f"Init directory: {Path.cwd()}")
    resuming_dir, resuming_hash = utils.config.setup_resuming_dir(config)
    logger.info(f"Run can be resumed from the directory: {resuming_dir}")
    if config.resuming.resume:
        os.chdir(resuming_dir)
        logger.info(f"Resuming from the directory: {Path.cwd()}")
        # You can still access the checkpoint directory for analysis etc even if not resuming with config.resuming_dir.

    postprocess_and_save_config(config)

    # If wandb.init hangs, it's likely that you're resuming a run that you already deleted on wandb.
    # Increment config.resuming.wandb_cache_bust to start a new run.

    # To resume a run in a sweep, find its wandb run id and pass it to the script alongside the same arguments
    # the sweep agent started the run with.

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

    # Use a custom step key when you log so that you can resume logging anywhere.
    # For example, if the checkpoint is earlier than the last logged step in the crashed run, you can resume
    # from steps already logged, and they will be rewritten (with the same value assuming reproducibility).
    # E.g., wandb.log({"my_custom_step": i, "loss": loss})

    # Re-log to capture log with wandb.
    logger.info(f"Running command: {subprocess.list2cmdline(sys.argv)}")
    logger.info(f"Init directory: {config.run_dir}")
    logger.info(f"Run can be resumed from the directory: {resuming_dir}")
    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Running with config: \n{OmegaConf.to_yaml(config)}")
    if config.resuming.resume:
        logger.info(f"Resuming from the directory: {Path.cwd()}")

    # Update this function whenever you have a library that needs to be seeded.
    utils.seeding.seed_everything(config)

    # Example experiment
    files = sorted(
        Path.cwd().glob("file_*.txt"), key=lambda x: int(x.stem.split("_")[1])
    )
    if files:
        last_file = files[-1]
        logger.info(f"Resuming from {last_file.stem}")
        i = int(last_file.stem.split("_")[1]) + 1
    else:
        i = 0

    steps = 0
    while i < 30:
        # Compute and log x**n.
        y = i * config.n
        logs = {"i": i, "y": y}
        print(logs)
        wandb.log(logs)

        # Checkpoint every 5 steps.
        if i % 5 == 0:
            with open(f"file_{i}.txt", "w") as f:
                f.write(f"y={y}")
                logger.info(f"Checkpointing at {i}")

        i += 1
        steps += 1

        # Preempt every 13 steps.
        if steps == 13:
            raise InterruptedError("Preempt after 13 steps.")

        sleep(1)

    logger.info("Finished writing files")


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
