import random


def generate_random_seed():
    """Generate a random seed."""
    return random.randint(0, 2**32 - 1)


# Update this function whenever you have a library that needs to be seeded.
def seed_everything(config):
    """Seed all random generators."""
    random.seed(config.seed)
