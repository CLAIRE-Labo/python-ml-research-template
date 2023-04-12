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
    TODO
    ```

You can then add more dependencies as your project grows following
the [instructions to maintain the environment](#instructions-to-maintain-the-environment).

## [_DELETE ME_] More details on the setup

Big acknowledgements to Cresset.


## Instructions to install the environment

Steps prefixed with [CUDA] are only required to use NVIDIA GPUs.

**Prerequisites**

To check if you have each of them run `<command-name> --version` or `<command-name> version`.

* [`make`](https://cmake.org/install/).
* [`docker`](https://docs.docker.com/engine/). (v20.10+)
* [`docker compose`](https://docs.docker.com/compose/install/) (V2)
* [CUDA] [Nvidia CUDA Driver](https://www.nvidia.com/download/index.aspx) (Only the driver. No CUDA toolkit, etc)
* [CUDA] [`nvidia-docker`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) (
  the NVIDIA Container Toolkit).

**Installation**

All commands should be run from the installation directory.
```bash
cd installation/amd64
```

1. Create an environment file for your personal configuration with
   ```bash
   make env
   ```
   The creates a `.env` file with pre-filled values.
   The `SERVICE_NAME` variable determines how you'll deploy your image.
   We provide 2 options.
      1. `image-only` does not specify any deployment options. 
         It is there if you only need to build the image and can then deploy it however you want.
         *: Use this option for deploying on the RunAI Kubernetes Cluster.
      2. `run-local` specifies a deployment with Docker Compose on your local machine.
         *: Use this option to run the container locally. E.g. on your WSL machine, EPFL HaaS lab machine.
   The `UID/GID` are used to give the container user read/write access to the mounted volumes 
   containing the code of the project, the data, and where you'll write your outputs.
   These need to match the user permissions on the mounted volumes.
   If you're deploying locally these values should be filled correctly by default.
   If you're deploying locally with Docker Compose, `LOCAL_*_DIR` are the paths to volumes to mount.
   Otherwise, they're not used.
2. Build the image with
   ```bash
   make build
   ```
3. You can then use the image in multiple ways.
   1. Locally
   2. In a managed cluster

## Instructions to maintain the environment

System dependencies are managed by both`apt` and `conda`.
Python dependencies are be managed by both `conda` and `pip`.

Use `apt` for system programs (e.g. `sudo`, `zsh`).
Use `conda` for non-python dependencies needed to run the project code (e.g. `mkl`, `swig`)
and dependencies packaged with more that just python code (e.g. `pytorch`, `numpy`).
These will typically be your main dependencies and will likely not change as your project grows.
Use `pip` for the rest of the python dependencies.

Here are references and reasons to follow the above claims:
* [A guide for managing `conda` + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to  use `conda` for not-python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining `conda` and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

You can add/upgrade dependencies interactively while running a shell in the container to experiment with which dependency is needed.
In that case you need to persist those changes and build the image again for subsequent runs.
We provide a script for that.
Otherwise, you can manually edit the dependencies files and build the image again.
This will be needed if you run into conflicts and have to restart from scratch.

### While developing

`conda` dependencies should all be installed before any `pip` dependency.
This will cause conflicts otherwise as id doesn't track the `pip` dependencies.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to recreate
the environment. (See how to in the next section.)

To add `apt` or `conda`/`pip` dependencies run `sudo apt-istall install <package>`
or `(conda | pip) install <package>` respectively.
Whenever you add a dependency interactively (e.g. `conda install <package>` or `pip install <package>`)
update/freeze the `environment.yml` file with

```bash
source dependencies/update_env_file.sh
```

For `apt` dependencies add them manually to `apt.txt`.

### While building