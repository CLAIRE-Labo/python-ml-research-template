# Resolvers can be used in the config files.
# https://omegaconf.readthedocs.io/en/latest/custom_resolvers.html
# They are useful when you want to make the default values of some config variables
# result from direct computation of other config variables.
# Only put variables meant to be edited by the user (as opposed to read-only variables described below)
# and avoid making them too complicated, the point is not to write code in the config file.
from omegaconf import OmegaConf

from template_package_name import utils


def register_resolvers():
    if not OmegaConf.has_resolver("eval"):
        # Useful to evaluate expressions in the config file.
        OmegaConf.register_new_resolver("eval", eval, use_cache=True)
    if not OmegaConf.has_resolver("generate_random_seed"):
        # Generate a random seed and record it in the config of the experiment.
        OmegaConf.register_new_resolver(
            "generate_random_seed", utils.seeding.generate_random_seed, use_cache=True
        )
