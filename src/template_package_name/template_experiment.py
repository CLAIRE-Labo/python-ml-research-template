# An example file to run an experiment.
# Keep this, it's used as an example to run the code after a user installs the project.

import logging
from pathlib import Path

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
    postprocess_config(config)

    handle_resuming(config)

    wandb.init(
        config=OmegaConf.to_container(config),
        project=config.wandb.project,
        tags=config.wandb.tags,
        anonymous=config.wandb.anonymous,
        mode=config.wandb.mode,
        dir=Path(config.wandb.dir).absolute(),
    )
    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Running with config: \n{OmegaConf.to_yaml(config)}")

    # Update this function whenever you have a library that needs to be seeded.
    utils.seeding.seed_everything(config)

    wandb.log({"some_metric": config.some_number + 1})


def postprocess_config(config):
    # Here you can make some computations with the config to add new keys, correct some values, etc.
    # E.g., read-only variables that can be useful when navigating the experiments on wandb (filtering, sorting, etc.).
    # Save the new config (as a file to record it) and pass it to wandb to record it with your experiment.
    Path("config/").mkdir()
    OmegaConf.save(config, "config/config-before-postprocess.yaml")
    with omegaconf.open_dict(config):
        config.some_new_key = "bar"
    OmegaConf.resolve(config)
    OmegaConf.save(config, "config/config-resolved.yaml")


def handle_resuming(config):
    if config.resuming.resume:
        # Create a hash of the config
        # remove the keys which do not influence the run
        config

        # Combine with a commit sha

        # Use it as the directory to stora the experiment
        pass
    return


if __name__ == "__main__":
    main()
