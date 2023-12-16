# An example file to run an experiment.
# Keep this, it's used as an example to run the code after a user installs the project.

import logging
from pathlib import Path

import hydra
import wandb
from omegaconf import DictConfig, OmegaConf

from template_package_name import utils

# Hydra sets up the logger automatically.
# https://hydra.cc/docs/tutorials/basic/running_your_app/logging/
logger = logging.getLogger(__name__)

# Resolvers can be used in the config files.
# https://omegaconf.readthedocs.io/en/latest/custom_resolvers.html
# They are useful when you want to make the default values of some config variables
# result from direct computation of other config variables.
# Only put variables meant to be edited by the user (as opposed to read-only variables described below)
# and avoid making them too complicated, the point is not to write code in the config file.

# Useful to evaluate expressions in the config file.
OmegaConf.register_new_resolver("eval", eval, use_cache=True)
# Generate a random seed and record it in the config of the experiment.
OmegaConf.register_new_resolver(
    "generate_random_seed", utils.seeding.generate_random_seed, use_cache=True
)


@hydra.main(version_base=None, config_path="configs", config_name="template_experiment")
def main(config: DictConfig) -> None:
    # Here you can make some computations with the config to add new keys, correct some values, etc.
    # E.g., read-only variables that can be useful when navigating the experiments on wandb (filtering, sorting, etc.).
    # Save the new config (as a file to record it) and pass it to wandb to record it with your experiment.

    wandb.init(
        config=OmegaConf.to_container(config, resolve=True, throw_on_missing=True),
        project=config.wandb.project,
        tags=config.wandb.tags,
        anonymous=config.wandb.anonymous,
        mode=config.wandb.mode,
        dir=Path(config.wandb.dir).absolute(),
    )

    logger.info(f"Working directory: {Path.cwd()}")
    logger.info(f"Running with config: \n{OmegaConf.to_yaml(config, resolve=True)}")

    # Update this function whenever you have a library that needs to be seeded.
    utils.seeding.seed_everything(config)

    wandb.log({"some_metric": config.some_number + 1})


if __name__ == "__main__":
    main()
