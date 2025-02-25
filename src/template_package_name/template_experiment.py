"""An example file to run an experiment.
Keep this, it's used as an example to run the code after a user installs the project.
"""

import logging
from pathlib import Path
from time import sleep

import hydra
import wandb
from omegaconf import DictConfig

from template_package_name import utils

# Refers to utils for a description of resolvers
utils.config.register_resolvers()

# Hydra sets up the logger automatically.
# https://hydra.cc/docs/tutorials/basic/running_your_app/logging/
logger = logging.getLogger(__name__)


@hydra.main(version_base=None, config_path="configs", config_name="template-experiment")
def main(config: DictConfig) -> None:
    # Using the template provides utilities for experiments:

    # 1. Setting up experiment and resuming directories
    config = utils.config.setup_config_and_resuming(
        config, postprocess_func=lambda x: x
    )
    # The current working directory is a new directory unique to this run made by hydra, accessible by config.run_dir.
    # A resuming directory uniquely identified by the config (and optionally the git sha)
    # for storing checkpoints of the same experiment can be accessed via config.resuming.dir.
    # The current directory will be the resuming directory if config.resuming.resume is True else the run directory.
    # You can pass a postprocessing function to postprocess the config.

    # 2. Setting up wandb with resuming and the config logged.
    utils.config.setup_wandb(config)
    # Use a custom step key when you log so that you can resume logging anywhere.
    # For example, if the checkpoint is earlier than the last logged step in the crashed run, you can resume
    # from steps already logged, and they will be rewritten (with the same value assuming reproducibility).
    # E.g., wandb.log({"my_custom_step": i, "loss": loss})

    # 3. Seeding for reproducibility
    utils.seeding.seed_everything(config)
    # Update this function whenever you have a library that needs to be seeded.

    # Example experiment:
    checkpoints = sorted(
        Path.cwd().glob("checkpoint_*.txt"), key=lambda x: int(x.stem.split("_")[1])
    )
    if checkpoints:
        last_file = checkpoints[-1]
        logger.info(f"Resuming from {last_file.stem}")
        i = int(last_file.stem.split("_")[1]) + 1
        # Important:
        # When resuming, you should recover the state of the experiment as it was when it was interrupted.
        # I.e., the random state, the state of the model, the optimizer, etc.
    else:
        i = 0

    steps = 0
    while i < 30:
        # Compute and log i*n.
        logs = {"i": i, "y": i * config.n}
        print(logs)
        wandb.log(logs)

        # Checkpoint every 5 steps.
        if i % 5 == 0:
            with open(f"checkpoint_{i}.txt", "w") as f:
                f.write(f"y={logs['y']}")
                logger.info(f"Checkpointing at {i}")

        sleep(1)
        i += 1
        steps += 1

        # Preempt every 13 steps.
        if steps == 13:
            raise InterruptedError("Preempt after 13 steps.")

    logger.info("Finished writing files")


if __name__ == "__main__":
    main()
