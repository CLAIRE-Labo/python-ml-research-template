# Installation on amd64 platforms with Docker

## [_DELETE ME_] Template info

This template provides a Docker setup to use the environment.
For information on the setup refer to the next template section [(_More details on the
setup_)](#_delete-me_-more-details-on-the-setup).
The python version and package name have already been filled by the `fill_template.sh` script.
It remains to

1. Specify your initial dependencies.
   Follow the instructions to maintain the environment up to (including) the manual editing section.
2. Create the environment following the user instructions to build the environment.
3. Run the environment following the user instructions to run the environment.
4. If everything works fine, (we suggest trying to import your dependencies and running simple scripts), then
   pin the dependencies you just got.
    ```bash
    TODO
    ```

You can then add more dependencies as your project grows following
the [instructions to maintain the environment](#instructions-to-maintain-the-environment).

## [_DELETE ME_] More details on the setup

Todo. Big acknowledgements to Cresset.
These acknowledgement should also be in the public instructions, not only the template sections.

## Instructions to build the environment

**Prerequisites**

* `make` (`make --version`). [Install here.](https://cmake.org/install/)
* `docker` (`docker --version`). [Install here.](https://docs.docker.com/engine/)
* `docker compose` (`docker compose version` >= TODO). [Install here.](https://docs.docker.com/compose/install/)

**build**

We recommend building on an `amd64` platform, although the Docker BuildKit allows building for different
platforms. Use at your own risk.

All commands should be run from the installation directory.

```bash
cd installation/docker-amd64
```

1. Create an environment file for your personal configuration with
   ```bash
   make env
   ```
   This creates a `.user.env` file with pre-filled values.
    - The `UID/GID` are used to give the container user read/write access to the volumes that will be mounted
      when the container is run, containing the code of the project, the data, and where you'll write your outputs.
      These need to match the user permissions on the mounted volumes.
      (If you're deploying locally, i.e. where you're building, these values should be filled correctly by default.)

      (**EPFL Note:** _These will typically be your GASPAR credentials and will match the permissions
      on your lab NFS and HaaS machines._)
    - You can ignore the rest of the variables after `## For running:`.
      These don't influence the build, they will be used later to run your image.

2. Build the image with
   ```bash
   make build
   ```

## Instructions to run the environment

You can either run the environment locally or on a managed cluster.
Edit the `SERVICE` variable in the `.user.env` file to match how you want to run the image.

- `image-only` does not specify any deployment options.
  It is there if you only need to build the image and then deploy it however you want.

  (**EPFL note:** _Use this option for deploying on the RunAI Kubernetes Cluster
  and refer to the `./EPFL_runai_setup/README.md` for more details._)
- `local-cpu` specifies a deployment with Docker Compose on your machine with no hardware acceleration.
  Use this option to run the container on a machine with Docker Compose. E.g. on your ssh server, WSL machine.
- `local-gpu` same as above with GPU support.

  (**EPFL note:** _Use this option for deploying on HaaS machines._)

For local deployments follow the instructions below.
For managed cluster deployments, EPFL RunAI cluster users can refer to the `./EPFL_runai_setup/README.md` for more
details.
Other users can get inspiration from it too, otherwise we leave it to you to deploy on your managed cluster.

**Prerequisites**

Steps prefixed with [CUDA] are only required to use NVIDIA GPUs with `SERVICE=local-gpu`.

* `make` (`make --version`). [Install here.](https://cmake.org/install/)
* `docker` (`docker --version`). [Install here.](https://docs.docker.com/engine/)
* `docker compose` (`docker compose version` >= TODO). [Install here.](https://docs.docker.com/compose/install/)
* [CUDA] [Nvidia CUDA Driver](https://www.nvidia.com/download/index.aspx) (Only the driver. No CUDA toolkit, etc)
* [CUDA] `nvidia-docker` (the NVIDIA Container
  Toolkit). [Install here.](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

**Run**

Edit the `.user.env` to specify the local directories to mount the project code, data, and outputs.
These are specified by the `LOCAL_*_DIR` variables.
Then you can

Start the container with

```bash
make up
```

Open a shell in the container with

```bash
make exec
```

Run independent jobs in separate containers with

```bash
make run command="python --version"
```

The not-so-nice syntax is due to `make` which is not really made to be used like this.
Otherwise, you can run

```bash
docker compose -p ${COMPOSE_PROJECT} run --rm ${SERVICE} python --version
```

## Instructions to maintain the environment

System dependencies are managed by both`apt` and `conda`.
Python dependencies are be managed by both `conda` and `pip`.

- Use `apt` for system programs (e.g. `sudo`, `zsh`).
- Use `conda` for non-python dependencies needed to run the project code (e.g. `mkl`, `swig`)
  and dependencies packaged with more that just python code (e.g. `pytorch`, `numpy`).
  These will typically be your main dependencies and will likely not change as your project grows.
- Use `pip` for the rest of the python dependencies.
- For more complex dependencies that may require a custom installation or build, use the `Dockerfile` directly.

Here are references and reasons to follow the above claims:

* [A guide for managing `conda` + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to  use `conda` for not-python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining `conda` and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

There are two ways to add dependencies to the environment:

1. **Manually edit the dependencies files.**
   This will be needed the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell in the container to experiment with which
   dependency is needed.
   This is probably what you'll be doing after building the image for the first time.

In both cases, after any change, a snapshot of the full environment specification should be written to the dependencies
files.
We describe how to do so in the freeze the environment section.

### Manual editing (before/while building)

- To edit the `apt` dependencies, edit the `dependencies/apt.txt` file.
- To edit the `conda` and `pip` dependencies, edit the `dependencies/environment.yml` file.
- To edit the more complex dependencies, edit the `Dockerfile`.

### Interactively (while developing)

`conda` dependencies should all be installed before any `pip` dependency.
This will cause conflicts otherwise as `conda` doesn't track the `pip` dependencies.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to recreate
the environment by manually adding the dependencies before the build as described in the previous section.

* To add `apt`  dependencies run `sudo apt-istall install <package>`
* To add `conda` dependencies run `(conda | pip) install <package>`

### Freeze the environment

After any change to the dependencies, a snapshot of the full environment specification should be written to the
dependencies files.
This includes changes during a build and changes made interactively.
This is to ensure that the environment is reproducible and that the dependencies are tracked at any point in time.

To do so, run the following with a shell in the container:

```bash
source dependencies/update_env_file.sh
```

For `apt` dependencies add them manually to `apt.txt`.

## Troubleshooting