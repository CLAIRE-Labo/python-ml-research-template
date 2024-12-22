# Resolvers can be used in the config files.
# https://omegaconf.readthedocs.io/en/latest/custom_resolvers.html
# They are useful when you want to make the default values of some config variables
# result from direct computation of other config variables.
# Only put variables meant to be edited by the user (as opposed to read-only variables described below)
# and avoid making them too complicated, the point is not to write code in the config file.
import logging
import subprocess
from hashlib import blake2b
from pathlib import Path

from omegaconf import DictConfig, OmegaConf, omegaconf

from template_package_name import utils

# Hydra sets up the logger automatically.
# https://hydra.cc/docs/tutorials/basic/running_your_app/logging/
logger = logging.getLogger(__name__)


def register_resolvers():
    if not OmegaConf.has_resolver("eval"):
        # Useful to evaluate expressions in the config file.
        OmegaConf.register_new_resolver("eval", eval, use_cache=True)
    if not OmegaConf.has_resolver("generate_random_seed"):
        # Generate a random seed and record it in the config of the experiment.
        OmegaConf.register_new_resolver(
            "generate_random_seed", utils.seeding.generate_random_seed, use_cache=True
        )


def maybe_save_config(config, path):
    """Save if it doesn't exist otherwise (in case of resuming) assert that the config is the same."""
    if not Path(path).exists():
        OmegaConf.save(config, path)
    else:
        new_config = config.copy()
        remove_excluded_keys(new_config, config.resuming.exclude_keys)
        existing_config = OmegaConf.load(path)
        remove_excluded_keys(existing_config, config.resuming.exclude_keys)
        try:
            OmegaConf.resolve(new_config)
            OmegaConf.resolve(existing_config)
            assert new_config == existing_config
        except AssertionError:
            logger.error(f"Config to resume is different from the one saved in {path}")
            raise AssertionError


def remove_excluded_keys(config: DictConfig, exclude_keys: list[str]):
    """Remove keys from the config that are specified in exclude_keys.
    exclude_keys are of the form "key1.key2.key3" to remove the key3 from the key1.key2 dictionary.
    """
    with omegaconf.open_dict(config):
        for key in exclude_keys:
            keys = key.split(".")
            val = config
            for key_ in keys[:-1]:
                val = val[key_]
            del val[keys[-1]]


def setup_resuming_dir(config):
    """Create a unique identifier of the experiment used to specify a resuming/checkpoint directory.
    The identifier is a hash of the config, excluding keys specified in config.resuming.exclude_keys.
    If config.resuming.use_commit is True, the commit hash is appended to the identifier.
    I.e. the checkpoint directory is defined by: the config - the excluded config keys + the commit hash (if specified)
    """
    if config.resuming_dir is not None:
        return Path(config.resuming_dir), Path(config.resuming_dir).name

    resuming_hash = ""
    config_to_hash = config.copy()

    # resolve config
    OmegaConf.resolve(config_to_hash)
    remove_excluded_keys(config_to_hash, config.resuming.exclude_keys)
    config_hash = blake2b(str(config_to_hash).encode(), digest_size=8).hexdigest()
    resuming_hash += config_hash
    if config.resuming.use_commit:
        commit_hash = (
            subprocess.check_output(["git", "rev-parse", "HEAD"])
            .strip()
            .decode("utf-8")
        )
        resuming_hash += f"-{commit_hash[:8]}"

    resuming_dir = Path.cwd().parent / "checkpoints" / resuming_hash
    resuming_dir.mkdir(parents=True, exist_ok=True)
    with omegaconf.open_dict(config):
        config.resuming_dir = str(resuming_dir)

    return resuming_dir, resuming_hash
