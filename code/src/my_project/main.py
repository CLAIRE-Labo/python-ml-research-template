import hydra
from omegaconf import DictConfig, OmegaConf

import time

import numpy as np


@hydra.main(version_base=None, config_path="configs", config_name="config")
def main(cfg: DictConfig) -> None:
    print(OmegaConf.to_yaml(cfg))
    rng = np.random.default_rng()

    N = cfg.N

    # The performance boost is more dramatic for single precision.
    m1 = rng.random((N, N), dtype='float32')
    m2 = rng.random((N, N), dtype='float32')

    start = time.time()
    m1.dot(m2)
    print("{:.2f}".format(time.time() - start))


if __name__ == "__main__":
    main()
