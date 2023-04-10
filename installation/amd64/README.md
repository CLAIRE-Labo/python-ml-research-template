# Installation on amd64 with Docker

## [_DELETE ME_] Template info

This template provides a Docker setup to use the environment.
For information on the setup refer to the next template section [(_More details on the
setup_)](#_delete-me_-more-details-on-the-setup).
The python version and package name have already been filled by the `fill_template.sh` script.
It remains to

1. Create the environment following the
   user [instructions to install the environment](#instructions-to-install-the-environment).
2. Pin the initial dependencies you just got.
    ```bash
    source installation/osx-arm64/update_env_file.sh 
    ```

You can then add more dependencies as your project grows following
the [instructions to maintain the environment](#instructions-to-maintain-the-environment).

## [_DELETE ME_] More details on the setup

## Instructions to install the environment

Steps prefixed with [CUDA] are only required for the CUDA option.

**Prerequisites**

To check if you have each of them run `<command-name> --version` or `<command-name> version`.

* [`make`](https://cmake.org/install/).
* [`docker`](https://docs.docker.com/engine/). (v20.10+)
* [`docker compose`](https://docs.docker.com/compose/install/) (V2)
* [CUDA] [Nvidia CUDA Driver](https://www.nvidia.com/download/index.aspx) (Only the driver. No CUDA toolkit, etc)
* [CUDA] [`nvidia-docker`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) (
  the NVIDIA Container Toolkit).

**Installation**

## Instructions to maintain the environment

System dependencies are managed by both`apt` and `conda`.
Python dependencies are be managed by both `conda`
and `pip`.
[(Here is a guide for managing `conda` + `pip` environments)](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).

Use `apt` for system programs (e.g. `sudo`, `zsh`).
Use `conda` for non-python dependencies needed to run the project code (e.g. `swig`),
dependencies packaged with more that just python code (
e.g. `pytorch`),
and most python dependencies (as much as possible).
Use `pip` for the rest of the python dependencies.
[(Here are reasons why you should use `conda` whenever possible)](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).

To add conda or apt dependencies run `conda install <package>` or `sudo apt-istall install <package>` respectively.
Whenever you add a dependency interactively (e.g. `conda install <package>` or `pip install <package>`)
update the `environment.yml` file with

```bash
source dependencies/update_env_file.sh
```

For `apt` dependencies add them manually to `apt.txt`.

`conda` dependencies should all be installed before any `pip` dependency.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to recreate
the environment.
For that, add the dependency to the `conda` section of the `environment.yml` file and recreate the environment as in the
previous section.

You might also need users to install system dependencies.
Use `conda` for those if possible, otherwise specify how to install those in the system dependencies section of
[_Instructions to install the environment_](#instructions-to-install-the-environment).