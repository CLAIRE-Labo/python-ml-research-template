# Installation with Docker (or any OCI container engine)

## Template getting started

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Follow the instructions, then delete this section.

This template provides a Docker setup to define your environment.
For detailed information on the setup, refer to the next section [(_More details on the
setup_)](#more-details-on-the-setup).
Follow the steps below to get started.
Some steps will send you to different sections of the document.
It may feel like jumping back and forth, but everything should read nicely after the setup
for your future users (and yourself).

1. Choose the platform and hardware acceleration that you will build the image for.
   You have to pick one as fully specified environment files are not trivially portable across platforms
   and hardware accelerations.
   Available packages may differ for different platforms and hardware accelerations,
   so in general, you cannot freeze an environment used for a platform and create it in another.

   The default platform is Linux (fixed) on AMD64 CPUs `amd64` (can be changed to e.g. `arm64`)
   with support for NVIDIA GPUs.
   (reflected in the name of the directory `docker-amd64-cuda` by default).
   (The EPFL Run:ai and the SCITAS clusters are on `amd64`, the CSCS Todi cluster is on `arm64`.)
   If this is good for you, you can skip this part.
   Otherwise, to edit it, run
   ```bash
   # When in the PROJECT_ROOT directory.
   # For examples run:
   ./installation/edit-platform-and-acceleration.sh
   # To do the change run:
   ./installation/edit-platform-and-acceleration.sh change docker CURR_PLATFORM CURR_ACCELERATION NEW_PLATFORM NEW_ACCELERATION
   # The hardware acceleration will be determined by the packages you install.
   # E.g. if you install PyTorch with CUDA, set the acceleration to cuda.
   ```
   If you plan to support multiple platforms or hardware accelerations,
   you can duplicate this installation method directory
   with `./installation/edit-platform-and-acceleration.sh copy ...`
   then perform the setup again.
   You could also try to adapt the Docker files to support multiple platforms
   (in some cases, may just get away with adding a line to the build platforms,
   and in others may need separate Dockerfiles and environment files.
   Test them, and ensure your results/conclusions hold across platforms.)
2. Run the rest of the commands from this `installation/docker-amd64-cuda` directory.
   ```bash
   cd installation/docker-amd64-cuda
   ```
3. Choose whether you will start your image from an existing image already having a Python environment
   (recommended)(e.g., the [NGC images](https://catalog.ngc.nvidia.com/containers) which have
   well-configured hardware-acceleration dependencies)
   or from scratch (Ubuntu image and new conda environment):
    - (Recommended) The `from-python` installation assumes that you base your image from an image which
      already has a Python environment and that this environment is well configured
      to be extended with pip, independently of how Python is installed
      (e.g. if with system Python like the NGC Pytorch image, you have nothing to do, but if with conda then
      the environment must be configured to be activated by default or you have to edit the Dockerfile).

      This is a great option to get started quickly with a well-tuned environment, and only add missing
      dependencies.
      However, this comes at the cost of not choosing your Python version and
      not having a granular choice over your dependencies.
    - The `from-scratch` installation is based on an Ubuntu image (which you can change if you want), installs
      conda and manages all the dependencies with it.

      This is a good option if you want full control over your environment, e.g., know exactly which system packages
      are installed, pick the Python version, pick all the Python dependencies, etc.

   The default base is `from-python` to quickly get started with the NGC images.
   Run the following if you want to edit it.
   ```bash
   # from-base can be from-scratch or from-python
   ./template.sh edit_from_base <from-base>
   ```
   Typically, you would support a single image per platform and hardware acceleration,
   however, if your use case requires multiple images
   (say you are using different RL environments with completely different dependencies),
   you can further duplicate the installation directory (as for supporting multiple platforms)
   and tag each of them by its specifics.
   The template doesn't provide helper scripts for this,
   but you can refer to the [Troubleshooting section](#supporting-multiple-images) for guidance.
4. Edit `compose-base.yaml` to specify your base image (`BASE_IMAGE`) and its eventual options.
   E.g., the NGC image you use as a base image and its entrypoint (`BASE_ENTRYPOINT`) in the `from-python` option
   or the Ubuntu and conda version (`CONDA_URL`) in the `from-scratch` option.
5. You can try to specify your dependencies if you are sure of how to install them and that they are compatible.
   Otherwise, you should build with the default dependencies and install them interactively in the running container
   then freeze them in the dependency files once you are sure of which to include and how to include them.
   You will find more information in
   the [instructions to maintain the environment](#from-python-instructions-to-maintain-the-environment).
   Delete the section of the from-base you are not using.

   If you change the dependency files commit so that you can track what worked and what didn't.
6. Build the environment following the instructions to [build the environment](#obtainingbuilding-the-environment).
   (Obviously, you'll have to build the generic image not pull it.)
   For CSCS todi, steps 6, 7, and 8 are described in `./CSCS-Todi-setup/README.md`.
   Follow the instructions there.
7. Follow the instructions to [run the environment](#the-environment) with your target
   deployment option.
   If everything goes well (we suggested checking that all your dependencies are there
   and importing the complex ones), pin your dependencies following the
   instructions to [freeze the environment](#freeze-the-environment).
8. Push your generic image (the one with the root user) to some registry if not done already.
   This will be handy for you, for sharing it with your teammates, and when you open-source your project later.
    1. Find a public (or private for teammates) repository to push your generic image.
       E.g., your personal Docker Hub registry has free unlimited public repositories.
    2. Push the generic image to the registry you chose.
       ```bash
       # Don't include the tag. All relevant tags will be pushed (i.e. latest and commit-tagged).
       ./template.sh push_generic FULL_IMAGE_NAME_WITH_REGISTRY
       ```
    3. Add this link to the TODO ADD PULL_IMAGE_NAME in
       the [obtaining/building the environment](#obtainingbuilding-the-environment)
       section of the README.
       (**EPFL Note**: _you can give the link to your generic image on your lab's registry to your teammates
       e.g., ic-registry.epfl.ch/your-lab/your-gaspar/template-project-name_.)

9. Remove the template sections that you've completed from this file (indicated with **TEMPLATE TODO**)
   to only leave the instructions relevant to the next users.
10. Go back to the root README for the rest of the instructions to set the template up.

## More details on the setup

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Read/skim over this section, then delete it.

The setup is based on Docker and Docker Compose and is adapted from
the [Cresset template](https://github.com/cresset-template/cresset).
It is composed of Dockerfiles to build the image containing the runtime environment,
and Docker Compose files to set build arguments in the Dockerfile and run it locally.

Most of these files are templates that should suit most use cases.
They read project/user-specific information from the other files such as the project dependencies and user
configuration.
Typically, the files you will have to edit are `compose-base.yaml`, `.env`, and the `requirements.txt`
or `environment.yml` files,

Here's a summary of all the files in this directory.

```
docker-amd64-cuda/
├── Dockerfile                       # Dockerfile template. Edit if you are building things manually.
├── Dockerfile-user                  # Dockerfile template. Adds the dev and user layers.
├── compose-base.yaml                # Sets the build args for the Dockerfile.
│                                    # Edit to change the base image or package manager.
├── compose.yaml                     # Docker Compose template. Edit if you have a custom local deployment or change the hardware acceleration.
├── template.sh                      # A utility script to help you interact with the template (build, deploy, etc.).
├── .env                             # Will contain your personal configuration. Edit to specify your personal configuration.
├── environment.yml                  # If chose the `from-scratch` option. Conda and pip dependencies.
├── requirements.txt                 # If chose the `from-python` option. pip dependencies.
├── apt.txt                          # Apt dependencies ("system" dependencies).
├── update-env-file.sh               # Template file. A utility script to update the environment files.
├── entrypoints/
│   ├── entrypoint.sh                # The main entrypoint that install the project and triggers other entrypoints.
│   ├── pre-entrypoint.sh            # Runs the base entrypoint of the base image if it has one.
│   ├── logins-setup.sh              # Manages logging into services like wandb.
│   └── remote-development-setup.sh  # Contains utilities for setting up remote development with VSCode, PyCharm, Jupyter.
└── *-setup/                         # Template files to deploy on the * cluster.
    ├── ...
    └── README.md                    # Instructions to deploy on * cluster.
```

### Details on the main Dockerfile

The Dockerfile specifies all the steps to build the environment in which your code will run.
It uses the files `apt.txt`, `requirements.txt`, and `environment.yml` to install the system and Python dependencies.
You typically don't have to edit the Dockerfile directly, unless you need to install dependencies manually
(not as a one time install from the dependencies files).
The `Dockefile-user` is used to build the user layer on top of the generic image for OCI runtimes with limitations
on user creation at container creation.

### Details on the Docker Compose files

The Docker Compose files are used to configure the build arguments used by the Dockerfile
when building the images and to configure the container when running it locally.

They support building multiple images corresponding to the runtime and development stages with or without a user
and running on each with either `cpu` or `cuda` support.

We provide a utility script, `template.sh`, to help you interact with Docker Compose.
It has a function for each of the main operations you will have to do.

You can always interact directly with `docker` or `docker compose` if you prefer
and get examples from the `./template.sh` script.

## The environment

> [!IMPORTANT]
> **TEMPLATE TODO:**
> When open-sourcing your project, share the generic image you built on a public registry.
> Otherwise, delete the last bullet below in the guides for running the environment.

We provide the following guides for obtaining/building and running the environment:

- To run the image locally (or on a remote server with SSH access) with Docker & Docker Compose, follow the instructions
  to [obtain/build the environment](#obtainingbuilding-the-environment) then
  the instructions [run locally with Docker Compose](#running-locally-with-docker-compose).

  Perform the steps on the machine where the code will run, i.e., your local machine or the remote server.

  The guide also provides instructions to do remote development with VSCode, PyCharm, and Jupyter Lab.
- To run on the EPFL Run:ai clusters, follow the instructions
  to [obtain/build the environment](#obtainingbuilding-the-environment)
  (perform them on your local machine)
  then refer to the `./EPFL-runai-setup/README.md`.

  The guide also provides instructions to do remote development on the Run:ai cluster
  with VSCode, PyCharm, and Jupyter Lab.
  Other Run:ai cluster users can get inspiration from it too.
- To run on the EPFL SCITAS clusters, follow the instructions
  to [obtain/build the environment](#obtainingbuilding-the-environment)
  (perform them on your local machine).
  You don't need to build the user image,
  and you can skip building the generic image if you're reusing an existing one for the project.
  Then, refer to the `./EPFL-SCIITAS-setup/README.md`.

  The guide also provides instructions to do remote development on the SCITAS cluster
  with VSCode, PyCharm, and Jupyter Lab.
  Other Slurm + enroot/Apptainer/Singularity cluster users can get inspiration from it too.
- To run on the CSCS Todi cluster, follow the instructions in `./CSCS-Todi-setup/README.md`.

  The guide also provides instructions to do remote development on the Todi cluster
  with VSCode, PyCharm, and Jupyter Lab.
  Other Slurm + enroot cluster users can get inspiration from it too.

- We also provide an image with the dependencies needed to run the environment
  that you can use with your favorite OCI-compatible container runtime.
  Follow the instructions
  in [Running with your favorite container runtime](#running-with-your-favorite-container-runtime) for the details.
  We give an example of how to run it with Apptainer/Singularity.

## Obtaining/building the environment

> [!IMPORTANT]
> **TEMPLATE TODO:**
> After pushing your generic image, provide the image name on your private registry to your teammates,
> or later on a public registry if you open-source your project.
> Add it below in the TODO ADD PULL_IMAGE_NAME.

### Prerequisites

* `docker` (A Docker Engine `docker version` >= v23). [Install here.](https://docs.docker.com/engine/)
* `docker compose` (`docker compose version` >= v2). [Install here.](https://docs.docker.com/compose/install/)

### Clone the repository

Clone the git repository.

```bash
git clone <HTTPS/SSH> template-project-name
cd template-project-name
```

### Obtain/build the images

All commands should be run from the `installation/docker-amd64-cuda/` directory.

```bash
cd installation/docker-amd64-cuda
```

1. Create an environment file for your personal configuration with
   ```bash
   ./template.sh env
   ```
   This creates a `.env` file with pre-filled values.
    - The `USRID` and `GRPID` are used to give the container user read/write access to the storage that will be mounted
      when the container is run with a container setup that does not change the user namespace
      (typically the case with rootful Docker and on the EPFL runai cluster).
      Edit them so that they match the user permissions on the mounted volumes, otherwise you can leave them as is.
      (If you're deploying locally, i.e., where you're building, these values should be filled correctly by default.)

      (**EPFL Note:** _These should match the permissions on your lab's shared storage when mounting from there
      and running on some shared infrastructure, like HaaS setup with LDAP login or Run:ai.
      They will typically be your GASPAR credentials.
      CLAIRE members should use the `claire-storage` group, refer to the compute doc on Notion._)
    - `LAB_NAME` will be the first element in name of the local images you get.

      (**EPFL Note:** _If pushing to the IC or RCP registries this should be the name of your lab's project
      in the registry.
      CLAIRE members should use `claire`._)
    - You can ignore the rest of the variables after `## For running locally`.
      These don't influence the build, they will be used later to run your image.

2. Pull or build the generic image.
   This is the image with root as user.
   It will be named according to the image name in your `.env`.
   It will be tagged with `<platform>-root-latest` and if you're building it,
   it will also be tagged with the latest git commit hash `<platform>-root-<sha>` and `<platform>-root-<sha>`.
    - Pull the generic image if it's available.
      ```bash
      # Pull the generic image if available.
      ./template.sh pull_generic TODO ADD PULL_IMAGE_NAME (private or public).
      ```
    - Otherwise, build it.
      ```bash
      ./template.sh build_generic
      ```
3. You can run quick checks on the image to check it that it has what you expect it to have:
   ```bash
   # Check all your dependencies are there.
   ./template.sh list_env

    # Get a shell and check manually other things.
    # This will only contain the environment and not the project code.
    # Project code can be debugged on the cluster directly.
    ./template.sh empty_interactive
   ```

4. Build the image configured for your user. (Not needed to run in containers with new namespaces like for the SCITAS and CSCS clusters)
   ```bash
   ./template.sh build_user
   ```
   This will build a user layer on top of the generic image
   and tag it with `*-${USR}` instead of `*-root`.
   This will be the image that you run and deploy to match the permissions on your mounted storage in container
   setups that maintain the user namespace (e.g., rootful Docker, the EPFL runai cluster).

For the local deployment option with Docker Compose, follow the instructions below.

For the EPFL Run:ai and SCITAS clusters you need to push the images to a registry, described below,
then get back to the instructions of the deployment option you're following.

### Push your image to the RCP or IC Docker registry

Push the generic image if you built it (`LAB_NAME/USR/PROJECT_NAME:PLATFORM-root-latest`).

```bash
./template.sh push_generic IC
# Or/and (both clusters can read from both registries)
./template.sh push_generic RCP
```

Pro-tip: it will also push them with the git commit hash as a tag if the build is at the latest commit.
You can rebuild the images with `./template.sh build` to tag them with the latest commit hash.

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Give the generic image name you just pushed
> (e.g., `ic-registry.epfl.ch/LAB_NAME/USR/PROJECT_NAME`)
> to your teammates so that they can directly build their user-configured images on top of it.
> Replace the _TODO ADD PULL_IMAGE_NAME_ above with this name.

Push the user-configured image for the Run:ai cluster (`LAB_NAME/USR/PROJECT_NAME:PLATFORM-USR-latest`)

```bash
./template.sh push_user IC
# Or/and (both clusters can read from both registries)
./template.sh push_user RCP
```

## Running locally with Docker Compose

> [!IMPORTANT]
> **TEMPLATE TODO:** Adapt the compose.yaml file to your local deployment needs.
> - Add the necessary container options (ipc=host, network, additional mounts, etc)
>   to the run-local and dev-local services in the compose.yaml file.
>
> - If you change the hardware acceleration:
>   1. change the `compose.yaml` file to adapt the
>      `run-local-cuda` and `dev-local-cuda` to the new hardware acceleration.
>   2. change the supported values of the `ACCELERATION` listed below.
>   3. change the prerequisites for the hardware acceleration.

**Prerequisites**

Steps prefixed with [CUDA] are only required to use NVIDIA GPUs.

* `docker` (A Docker Engine `docker version` >= v23). [Install here.](https://docs.docker.com/engine/)
* `docker compose` (`docker compose version` >= v2). [Install here.](https://docs.docker.com/compose/install/)
* [CUDA] [Nvidia CUDA Driver](https://www.nvidia.com/download/index.aspx) (Only the driver. No CUDA toolkit, etc.)
* [CUDA] The NVIDIA Container Toolkit. [Install here.](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

**Run**

Edit the `.env` file to specify which hardware acceleration to use with the `ACCELERATION` variable.
Supported values are `cpu` and `cuda`.

Then you can run jobs in independent containers running the runtime image.

These containers start with the entrypoint and then run the command you specified.
By default, they are automatically removed after they exit.
The container has an entrypoint that installs the project, checking that the code directory has correctly been mounted.
The Docker Compose run and dev services are already setup to mount the project code and specify its location
to the entrypoint.

You should not need to override the entrypoint of the container, it performs important setups.
It installs the project from its mounted location when specified to avoid hacky imports,
runs the original entrypoint of your base image if it exists,
and execs your command with PID 1.
Only do so if you need to debug the entrypoint itself or if you have a custom use case.

For the runtime service you can run commands directly in independent containers with
```bash
# template_experiment is an actual script that you can run.
./template.sh run your_command
./template.sh run python --version
./template.sh run python -m template_package_name.template_experiment some_arg=some_value
# You can pass environment variables to the container with the `-e VAR=VALUE` flag before your command
./template.sh run -e FOO=10 bash -c 'echo $FOO'
# E.g. open a tmux shell, then run containers there
tmux
./template.sh run your_command
# Detach from the tmux.
```

For the development service you can start it and then exec programs in it, or from a tmux shell
```bash
# To get a shell and run commands in the container
./template.sh dev
# To open a container a let it be (remember to stop it)
./template.sh dev -d
```

You can check how `./template.sh run` is running `docker-compose` commands if you want more control over the containers.
You can pass environment variables that the entrypoint can use to facilitate your development experience.
This is described in the following sections.

You should then return to the root README for the rest of the instructions to run our experiments.

We also recommend that you keep two different copies of the repository, one for the development code
and one for the runtime code so that you don't get containers running experiments reading code that
you're simultaneously developing.
You could for example

```bash
mv template-project-name template-project-name-tmp
mkdir template-project-name
mv template-project-name-tmp template-project-name/dev
# Make sure to rerun your .env so that the new paths are correct.
git clone <HTTPS/SSH> template-project-name/run
# Then you can follow the same steps for .../run to run your experiments.
# Remember to generate and edit the .env file there as well.
```

### Development

We support Pycharm Remote Development (Gateway), VSCode Remote Development, and Jupyter Lab.
For remote development, the template will open an SSH server in a dev container
that you can then use to connect your IDE to and do remote development inside with your usual debugging tools.

#### VS Code and PyCharm Professional Remote Development

```bash
# Start the dev container and an SSH server in it. Change the port if it's already used by another project.
./template.sh dev -d -e SSH_SERVER=1 -e SSH_CONTAINER_PORT=2223

# If the container is on your local machine you're good to go.

# If the container is on a remote machine, you should forward the ports to your local machine.
# Run the following on your local machine.
# ssh -N -L port-on-local-machine:container-ip:container-port <USER@HOST>
ssh -N -L 2223:localhost:2223 <USER@HOST> # or anything specified in your ssh config.
```

Add your forwarded server to your local machine's SSH config file.
```bash
# Add the following to your SSH config file (~/.ssh/config)
# If the container is on your local machine, without port forwarding
# Replace localhost by the address of the container and Port by 22.
Host local2223
	HostName localhost
	User <same-username-as-.env>
	Port 2223
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
	ForwardAgent yes
```

In case of issues, you can check the logs of the container with
```bash
# A container ID is outputted when you start the container.
docker logs -f <container-ID>
```

**Notes**

Directories for storing the IDE configurations, extensions, etc.
are mounted to the container to be persisted across development sessions.
You can find them in the `docker-compose.yaml` file.
Each project (defined by its `PROJECT_ROOT_AT` path) will have its own cache directory to avoid conflicts
between containers.

**VS Code**

The idea is to connect to an SSH remote server (the container) as described [here](https://code.visualstudio.com/docs/remote/ssh).

Install the [Remote Development extension in VSCode](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh).
Then connect to the remote server following the steps [here](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host).

Open the directory of your project which is mounted in the same location as in your local machine or remote server.

**PyCharm**

The idea is to run the IDE inside the SSH remote server (the container) as described [here](https://www.jetbrains.com/help/pycharm/remote-development-overview.html)

The first time connecting you will have to install the IDE in the container in a mounted directory
so that it is stored on your machine.
After that, or if you already have the IDE stored from another project,
the template will start the IDE mounted in the container at the container creation,
and you will be able to directly connect to it from the JetBrains Gateway client on your local machine.

The first time,
follow the steps [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway) to install the IDE,
and install it in `/home/YOUR-USERNAME/.jetbrains-server/dist`, not in its default location
(small "installation options..." link).
For the project directory, it should be mounted in the container at the same location as in your local machine.

In the container, locate the name of the PyCharm IDE installed.
It will be at
```bash
ls ${HOME}/.jetbrains-server/dist
# Outputs something like e632f2156c14a_pycharm-professional-2024.1.4
```
Copy the name of this directory to your `.env` file as the value of the `PYCHARM_IDE_AT` variable
so that the template can start the IDE for you next time.
```bash
PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4
```

The next time you start the development container, the IDE will start at the container start,
and you will find it in your JetBrains Gateway list of projects.
If it's a new host (e.g. one for a simultaneous container on port 2224), you can add it,
and it will detect that the IDE is already installed.

_Configuration_:

* PyCharm's default terminal is bash. Change it to zsh in the Settings -> Tools -> Terminal.
* When running Run/Debug configurations, set your working directory the project root (`$PROJECT_ROOT_AT`), not the script's directory.
* Your interpreter will be
  * the system Python `/usr/bin/python` with the `from-python` option.
  * the Python in your conda environment with the `from-scratch` option, with the conda binary found at `/opt/conda/condabin/conda`.



#### Jupyter Lab

With Jupyter Lab you should have the server running directly in the container
and then forward the ports to your local machine as follows:

```bash
# Start the jupyter server. Change the port if it's already used by another project.
./template.sh dev -d -e JUPYTER_SERVER=1 -e JUPYTER_PORT=8887
# Outputs a container ID.
# Get its logs to get the token.
docker logs -f <container-ID>
# The last line will be something like
# http://hostname:8887/?token=<TOKEN>
# Wait a bit if the server is not ready yet.
# Ctrl-C to quit the logs.

# If the container is on your local machine open the URL
# http://localhost:8887/?token=<TOKEN> on your local machine.

# If the container is on a remote machine, you should forward the ports to your local machine.
# Run the following on your local machine.
# ssh -N -L port-on-local-machine:container-ip:container-port <USER@HOST>
ssh -N -L 8887:localhost:8887 <USER@HOST> # or anything specified in your ssh config.
# Connect to the server with this URL on your local machine http://localhost:8887/?token=TOKEN
```

## Running with your favorite container runtime

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Provide the images and fill the TODO link and PULL_IMAGE_NAME, or delete this section.

An image with the runtime environment running as root
(but with a configured zshell for users specified at runtime as well)
is available at TODO: LINK TO PUBLIC IMAGE.

The tag is `amd64-cuda-root-latest` for the latest version and `amd64-cuda-root-SHA` for specific commits
referring to previous builds.
You can use your favorite container runtime to run these images.

They have an entrypoint which installs the project with pip
and expects it to be mounted in the container and its location specified with the
environment variable `PROJECT_ROOT_AT`.
E.g., you can mount it at `/project/template-project-name` and specify `PROJECT_ROOT_AT=/project/template-project-name`.
The entrypoint can then take any command to run in the container and will run it with PID 1.
(If you don't specify the `PROJECT_ROOT_AT`, the entrypoint will skip the project installation and warn you about it.)
It also expects the working directory to be set to `$PROJECT_ROOT_AT`.
We typically mount the project at the same location as the project root on the host.
You can refer to the `run-local-*` services in the `compose.yaml` file or to the `EPFL-runai-setup/README.md` file
for an idea of how this would work locally with Docker or on a Kubernetes cluster interfaced with Run:ai.

For example, on an HPC system with Apptainer/Singularity you could do
```bash
# After cloning the project, inside the PROJECT_ROOT on your system.
# E.g. apptainer pull docker://registry-1.docker.io/library/ubuntu:latest
apptainer pull PULL_IMAGE_NAME:amd64-cuda-root-latest

# Location to mount the project, also used by the entrypoint
export PROJECT_ROOT_AT=/project/template-project-name
apptainer run \
    -c \
    -B $(pwd):${PROJECT_ROOT_AT} \
    --cwd ${PROJECT_ROOT_AT} \
    --env PROJECT_ROOT_AT=${PROJECT_ROOT_AT} \
    --env WANDB_API_KEY="" \
    --nv template-project-name_amd64-cuda-root-latest.sif
# --env PROJECT_ROOT_AT is used by the entrypoint to install the project
# *.sif is the downloaded image.
# -c to not mount all the home directory to avoid spoiling reproducibility
# --nv to use NVIDIA GPUs
```

Return to the root README for the rest of the instructions to run our experiments.

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Remove the [FROM-PYTHON] or [FROM-SCRATCH] prefix of the method you use and delete the other method's section.

## [FROM-PYTHON] Instructions to maintain the environment

The environment is based on an image which already contains system and Python dependencies.
Extra dependencies are managed as follows:

System dependencies are managed by `apt`.
Python dependencies are managed by `pip`.

Complex dependencies that may require a custom installation
should have their instructions performed in the `Dockerfile` directly.

There are two ways to add dependencies to the environment:

1. **Manually edit the dependency files.**
   This is used the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell in the container to experiment with which
   dependency is needed.
   This is probably what you'll be doing after building the image for the first time.

In both cases, after any change, a snapshot of the full environment
specification should be written to the dependency files.
We describe how to do so in the Freeze the Environment section.

### Manual editing (before/while building)

- To add `apt` dependencies, edit the `apt.txt` file.
  Put the dependencies needed to build the environment, e.g., compilers, build tools, etc.
  and dependencies to run the environment, e.g., image processing libraries,
  and the utilities that will help you develop in the container, e.g. `htop`, `vim`, etc.

  If you're not familiar with which dependencies are needed, you can start with the minimal set we
  give, and when you encounter errors during the image build, add the missing dependencies to the stage where the error
  occurred.
- To edit `pip` dependencies, edit the `requirements.txt` file.
- To edit the more complex dependencies, edit the `Dockerfile`.

When manually editing the dependency files,
you do not need to specify the specific version of all the dependencies,
these will be written to the file when you freeze the environment.
You should just specify the major versions of specific dependencies you need.

### Interactively (while developing)

* To add `apt`  dependencies run `sudo apt install <package>` (in a rootful container),
  and `apt install <package>` (in a container with a mounted namespace where you are the new root user).
* To add `pip` dependencies run `pip install <package>`

### Freeze the environment

After any change to the dependencies, a snapshot of the full environment specification should be written to the
dependency files.
This includes changes during a build and changes made interactively.
This is to ensure that the environment is reproducible and that the dependencies are tracked at any point in time.

To do so, run the following from a login shell in the container.
The script overwrites the `requirements.txt` file with the current environment specification,
so it's a good idea to commit the changes to the environment file before/after running it.

The script isn't just a `pip freeze` and the file it generates isn't made to recreate the environment from scratch,
it is tightly coupled to the Dockerfile and the base image it uses.
In this sense, packages that are already installed in the base image or installed by the Dockerfile
may not be listed in the file or may be listed without a version
(this is because that may have been installed from wheels not present anymore in the final image).

The purpose of the generated `requirements.txt` is to be used always at the same stage of the Dockerfile
to install the same set of missing dependencies between its previous stage and its next stage.
(so not reinstall the dependencies already installed in the base image, for example).
In any case,
the Dockerfile also records the snapshots of the dependency files used to generate each stage for debugging that can be
found in the `/opt/template-dependencies/` directory.

```bash
update-env-file
```

The script isn't perfect, and there are some caveats (e.g., packages installed from GitHub with pip),
so have a look at the output file to make sure it does what you want.
The `update-env-file.sh` gives some hints for what to do,
and in any case you can always patch the file manually.

For dependencies that require a custom installation or build, edit the `Dockerfile`.
If one of these complex dependencies shows in the `requirements.txt` after the freeze,
you have to remove it, so that pip does not pick it up, and it is installed independently in the `Dockerfile`.
(Something similar is done in the `update-env-file`.)

For `apt` dependencies add them manually to the `apt-*.txt` files.

## [FROM-SCRATCH] Instructions to maintain the environment

System dependencies are managed by both `apt` and `conda`.
Python dependencies are managed by both `conda` and `pip`.

- Use `apt` for system programs (e.g. `sudo`, `zsh`, `gcc`),
  leave libraries (e.g., image libraries etc.) to `conda` whenever possible.
- Use `conda` for non-Python dependencies needed to run the project code (e.g. `mkl`, `swig`, `imageio`, etc.).
- Use `conda` for Python dependencies packaged with more than just Python code (e.g. `pytorch`, `numpy`).
  These will typically be your main dependencies and will likely not change as your project grows.
- Use `pip` for the rest of the Python dependencies.
- For more complex dependencies that may require a custom installation or build, use the `Dockerfile` directly.

Here are references and reasons to follow the above claims:

* [A guide for managing `conda` + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to  use `conda` for not-Python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining `conda` and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

There are two ways to add dependencies to the environment:

1. **Manually edit the dependency files.**
   This is used the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell in the container to experiment with which
   dependency is needed.
   This is probably what you'll be doing after building the image for the first time.

In both cases, after any change, a snapshot of the full environment specification should be written
to the dependency files.
We describe how to do so in the Freeze the Environment section.

### Manual editing (before/while building)

- To add `apt` dependencies, edit the `apt.txt` file.
  Put the dependencies needed to build the environment, e.g., compilers, build tools, etc.
  and dependencies to run the environment, e.g., image processing libraries,
  and the utilities that will help you develop in the container, e.g. `htop`, `vim`, etc.

  If you're not familiar with which dependencies are needed, you can start with the minimal set we
  give.
  When you encounter errors during the image build, add the missing dependencies to the stage where the error
  occurred.
- To edit the `conda` and `pip` dependencies, edit the `environment.yml` file.
- To edit the more complex dependencies, edit the `Dockerfile`.

When manually editing the dependency files,
you do not need to specify the specific version of all the dependencies,
these will be written to the file when you freeze the environment.
You should just specify the major versions of specific dependencies you need.

### Interactively (while developing)

`conda` dependencies should all be installed before any `pip` dependency.
This will cause conflicts otherwise as `conda` doesn't track the `pip` dependencies.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to recreate
the environment by manually adding the dependencies before the build as described in the previous section.

* To add `apt`  dependencies run `sudo apt install <package>`
* To add `conda` dependencies run `mamba install <package>`
* To add `pip` dependencies run `pip install <package>`

### Freeze the environment

After any change to the dependencies, a snapshot of the full environment specification should be written to the
dependency files.
This includes changes during a build and changes made interactively.
This is to ensure that the environment is reproducible and that the dependencies are tracked at any point in time.

To do so, run the following from a login shell in the container.
The script overwrites the `environment.yml` file with the current environment specification,
so it's a good idea to commit the changes to the environment file before/after running it.

The script isn't just a `mamba env export`
and the file it generates isn't made to recreate the complete environment from scratch,
it is tightly coupled to the Dockerfile.
In this sense, packages it installs may depend on system dependencies installed by the Dockerfile
and dependencies installed at later stages will not be listed.

**Note:** A strict `mamba env export` is recorded

The purpose of the generated `environment.yml` is to be used always at the same stage of the Dockerfile
to install the initial set of dependencies.
(and not install dependencies that the Dockerfile will build and install later).
In any case,
the Dockerfile also records the snapshots of the dependency files used to generate each stage for debugging that can be
found in the `/opt/template-dependencies/` directory.

```bash
update-env-file
```

The script isn't perfect, and there are some caveats (e.g., packages installed from GitHub with pip),
so have a look at the output file to make sure it does what you want.
The `update-env-file.sh` gives some hints for what to do,
and in any case you can always patch the file manually.

For dependencies that require a custom installation or build, edit the `Dockerfile`.
If one of these complex dependencies shows in the `environment.yml` after the freeze,
you have to remove it, so that conda does not pick it up, and it is installed independently in the `Dockerfile`.

For `apt` dependencies add them manually to the `apt-*.txt` files.

## Troubleshooting

### Supporting multiple images

In case you want to support multiple images for the same platform and hardware acceleration, you can do the following.
(Note that this can also be a way
to have both a `from-python` and `from-scratch` image for the same platform and hardware acceleration
if you want to benchmark/switch between them.)

1. Duplicate the installation directory. E.g.,
   ```bash
   mv installation/docker-amd64-cuda installation/docker-amd64-cuda-env1
   cp installation/docker-amd64-cuda-env1 installation/docker-amd64-cuda-env2
   ```
2. Add an additional field to the image tag for each installation directory.
   Edit the `./template.sh` and your `.env` if already created and edit
   ```bash
   IMAGE_PLATFORM=amd64-cuda-envX
   ```
   This is important so that your images are not mixed.
3. Follow the instructions for each installation directory.

### Debugging the Docker build

If your build fails at some point, the build will print the message with the line in the Dockerfile
that caused the error.
Identify the stage at in which the line is: it's the earliest FROM X as Y before the line.
Then add a new stage right before the failing line starting from the stage you identified.
Something like:

```dockerfile
FROM X as Y

RUN something-that-works

# Add this line.
FROM Y as debug

RUN something-that-breaks
```

Then in the `compose.yaml` file, change the `target: runtime-generic` to `target: Y`
(replacing Y with its correct stage name).
Your build will then stop at the line before the failing line.

```bash
# Say you're building the generic images.
./template.sh build_generic
```

You can open a shell in that layer and debug the issue.

```bash
# IMAGE_NAME and IMAGE_PLATFORM can be found in your .env file.
docker run --rm -it --entrypoint /bin/bash ${IMAGE_NAME}:${IMAGE_PLATFORM}-root-latest
```

### My image doesn't build with my initial dependencies.

Try removing the dependencies causing the issue, rebuilding, and then installing them interactively when running the
container.
The error messages will possibly be more informative, and you will be able to dig into the issue.

Alternatively, you can open a container at the layer before the installation of the dependencies,
like described above, and try to install the environment manually.

## Licenses and acknowledgements

This Docker setup is based on the [Cresset template](https://github.com/cresset-template/cresset)
with the LICENSE.cresset file included in this directory.
