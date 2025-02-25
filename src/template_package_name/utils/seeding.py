import os
import random

# import numpy as np
# import torch


def generate_random_seed():
    """Generate a random seed."""
    return random.randint(0, 2**32 - 1)


# Update this function whenever you have a library that needs to be seeded.
def seed_everything(config):
    """Seed all random generators."""
    random.seed(config.seed)

    ## For numpy:
    # This is for legacy numpy:
    # np.random.seed(config.seed)
    # New code should make a Generator out of the config.seed directly:
    # https://numpy.org/doc/stable/reference/random/generated/numpy.random.seed.html

    ## For PyTorch:
    # torch.manual_seed(config.seed)

    # if config.cuda_deterministic:
    #     # Higher (e.g., on CUDA too) reproducibility with deterministic algorithms:
    #     # https://pytorch.org/docs/stable/notes/randomness.html
    #
    #     # Not supported for all operations though:
    #     # https://pytorch.org/docs/stable/generated/torch.use_deterministic_algorithms.html
    #     if config.cuda_strong_deterministic:
    #         torch.use_deterministic_algorithms(True)
    #
    #     #  A lighter version of the above otherwise as not all algorithms have a deterministic implementation
    #     torch.backends.cudnn.deterministic = True
    #
    #     # torch.backends.cudnn.benchmark = False
    #     os.environ["CUBLAS_WORKSPACE_CONFIG"] = ":4096:8"
