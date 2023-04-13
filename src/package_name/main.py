import hydra
from omegaconf import DictConfig, OmegaConf
from <package_name>.numpy_benchmark import benchmark as numpy_benchmark
from <package_name>.pytorch_benchmark import benchmark as pytorch_benchmark


@hydra.main(version_base=None, config_path="configs", config_name="config")
def main(cfg: DictConfig) -> None:
    print(OmegaConf.to_yaml(cfg))

    # Example on how to use the config.
    numpy_benchmark.benchmark(cfg.numpy_benchmark.n)
    pytorch_benchmark.benchmark(cfg.pytorch_benchmark.b_cpu, cfg.pytorch_benchmark.b_gpu)

if __name__ == "__main__":
    main()
