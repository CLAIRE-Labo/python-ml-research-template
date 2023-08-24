import random


def generate_random_seed():
    """Generate a random seed."""
    return random.randint(0, 2**32 - 1)


def seed_everything(config):
    """Seed all random generators."""
    random.seed(config.seed)
