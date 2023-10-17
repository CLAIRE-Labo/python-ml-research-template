# An example file to run an experiment.

import logging
from pathlib import Path

import hydra
import wandb
from omegaconf import DictConfig, OmegaConf

from template_package_name import utils

# Hydra sets up the logger automatically.
# https://hydra.cc/docs/tutorials/basic/running_your_app/logging/
log = logging.getLogger(__name__)

# Resolvers can be used in the config files.
# https://omegaconf.readthedocs.io/en/latest/custom_resolvers.html

OmegaConf.register_new_resolver(
    "eval", eval, use_cache=True
)  # Useful to evaluate expressions in the config file.
OmegaConf.register_new_resolver(
    "generate_random_seed", utils.seeding.generate_random_seed, use_cache=True
)  # Generate a random seed and record it in the config of the experiment.


@hydra.main(version_base=None, config_path="configs", config_name="some_experiment")
def main(config: DictConfig) -> None:
    wandb.init(
        config=OmegaConf.to_container(config, resolve=True, throw_on_missing=True),
        project=config.wandb.project,
        tags=config.wandb.tags,
        anonymous=config.wandb.anonymous,
        mode=config.wandb.mode,
        dir=Path(config.wandb.dir).absolute(),
    )

    log.info(f"Running with config: \n{OmegaConf.to_yaml(config, resolve=True)}")

    utils.seeding.seed_everything(config)


if __name__ == "__main__":
    main()
