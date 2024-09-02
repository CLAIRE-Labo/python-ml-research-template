# Guide for using the template with the CSCS Todi cluster

## Overview

At this point, you should have edited the environment files and are ready to build or run the image.
This guide will show you how to build and run your image on the CSCS Todi cluster and use it for

1. Remote development.
2. Running unattended jobs.


## Building the environment (skip if already have access to the image)

> [!IMPORTANT]
> **TEMPLATE TODO:**
> After saving your generic image, provide the image location to your teammates.
> Ideally also push it to team registry and later on a public registry if you open-source your project.
> Add it below in the TODO ADD IMAGE PATH.

### Prerequisites

* `podman` (Already installed on the CSCS clusters). Configure it as described [here](https://confluence.cscs.ch/display/KB/LLM+Inference)
  (step after "To use Podman, we first need to configure some storage ...")
* `podman-compose` (A utility to run Docker compose files with Podman) [Install here](https://github.com/containers/podman-compose/tree/main)
  or follow the steps below for an installation from scratch on CSCS.

```bash
# Install Miniconda
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
# Follow the instructions
# Close and reopen your terminal
bash
# Create a new conda environment
mamba create -n podman python=3.10
mamba activate podman
pip install podman-compose

# Activate this environment whenever you use this template.
```

### Build the images

All commands should be run from the `installation/docker-amd64-cuda/` directory.

You should be on a compute node. If not already, get one.

```bash
cd installation/docker-amd64-cuda
```

1. Create an environment file for your personal configuration with
   ```bash
   ./template.sh env
   ```
   This creates a `.env` file with pre-filled values.
    - Edit the `DOCKER` variable to `podman` and the `COMPOSE` variable to `podman-compose`.
    - You can ignore the variables `USR, USRID, GRP, GRPID, and PASSW`.
    - `LAB_NAME` will be the first element in name of the local images you get.
      (**EPFL Note:** _If pushing to the IC or RCP registries this should be the name of your lab's project
      in the registry. CLAIRE members should use `claire`._)
    - You can ignore the rest of the variables after `## For running locally`.
2. Edit the Dockerfile to make it compatible with Podman:
   There are commented lines starting with `# Podman` which should be uncommented
   and replace the corresponding lines above them.
3. Build the generic image.
   This is the image with root as user.
   It will be named according to the image name in your `.env`.
   It will be tagged with `<platform>-root-latest` and if you're building it,
   it will also be tagged with the latest git commit hash `<platform>-root-<sha>` and `<platform>-root-<sha>`.
   ```bash
   # Make sure the Conda environment with podman-compose is activated.
   # mamba activate podman
   ./template.sh build_generic
   ```
4. Export the image to a file and move it to a directory where you keep the images.
   ```bash
   ./template.sh import_from_podman
   # Move the images
   # Make a directory where you store your images
   # Add it to your bashrc as it'll be used often
   CONTAINER_IMAGES=$SCRATCH/container-images
   mkdir -p $CONTAINER_IMAGES
   mv *.sqsh $CONTAINER_IMAGES
   ```
5. You can run quick checks on the image to check it that it has what you expect it to have.
   When the example scripts are described later, run the `test-interactive.sh` example script before the other scripts.

## First steps

### Prerequisites

**CSCS and Slurm**:

1. You should have access to the Todi cluster.
2. You should have some knowledge of Slurm.

There is a great documentation provided by the SwissAI initiative [here](https://github.com/swiss-ai/documentation).

### Getting your image

#### From a file

You will find the image to use for this project in _TODO ADD IMAGE_PATH_.
Copy it or create a symlink to it where you keep your images. E.g.,
```bash
# Make a directory where you store your images
# Add it to your bashrc as it'll be used often
CONTAINER_IMAGES=$SCRATCH/container-images
mkdir -p $CONTAINER_IMAGES
ln -s _TODO ADD IMAGE_PATH_ $CONTAINER_IMAGES/ADAPTED_NAME.sqsh
```

#### From a registry (TODO)

### Clone your repository in your scratch directory

We strongly suggest having two instances of your project repository.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

The outputs and data directories of those two instances will be symlinked to the scratch storage
and will be shared anyway.
This guide includes the steps to do it, and there are general details in `data/README.md` and `outputs/README.md`.

```bash
# SSH to a cluster.
ssh kuma
# Somewhere in your home directory on the clusters
SCRATCH=/scratch/kuma/$USER
# Or on Izar
# SCRATCH=/scratch/izar/$USER
cd $SCRATCH
# Clone the repo twice with name dev and run (if you already have one, mv it to a different name)
mkdir template-project-name
git clone <HTTPS/SSH> template-project-name/dev
git clone <HTTPS/SSH> template-project-name/run
```

The rest of the instructions should be performed on the cluster from the dev instance of the project.
```bash
cd $SCRATCH/template-project-name/dev/
# It may also be useful to open a remote code editor on a login node to view the project. (The remote development will happen in another IDE in the container.)
# Push what you did on your local machine so far (change project name etc) and pull it on the cluster.
git pull
cd template-project-name/dev/installation/docker-amd64-cuda
```

### Note about the examples

The example files were made with username `smoalla` and lab-name `claire`.
Adapt them accordingly to your username and lab name.
Run
```bash
./template.sh env
# Edit the .env file with your lab name (you can ignore the rest).
./template.sh get_cscs_scripts
```
to get a copy of the examples in this guide with your username, lab name, etc.
They will be in `./EPFL-SCITAS-setup/submit-scripts`.

### A quick test to understand how the template works

Adapt the `submit-scripts/minimal.sh` with the name of your image and your cluster storage setup.

The submission script gives an example of how to run containers on Todi with [`enroot`](https://github.com/NVIDIA/enroo)
and the [`pyxis`](https://github.com/NVIDIA/pyxis) plugin directly integrated in `srun`,

Run the script to see how the template works.
```bash
cd installation/docker-amd64-cuda//CSCS-Todi-setup/submit-scripts
bash minimal.sh
```

When the container starts, its entrypoint does the following:

- It runs the entrypoint of the base image if you specified it in the `compose-base.yaml` file.
- It expects you specify `PROJECT_ROOT_AT=<location to your project in scratch (dev or run)>`.
  and `PROJECT_ROOT_AT` to be the working directory of the container.
  Otherwise, it will issue a warning and set it to the default working directory of the container.
- It then tries to install the project in editable mode.
  This is a lightweight installation that allows to avoid all the hacky import path manipulations.
  (This will be skipped if `PROJECT_ROOT_AT` has not been specified or if you specify `SKIP_INSTALL_PROJECT=1`.)
- It also handles all the remote development setups (VS Code, PyCharm, Jupyter, ...)
  that you specify with environment variables.
  These are described in the later sections of this README.
- Finally, it executes a provided command (e.g. `bash` here for an interactive job with a connected --pty).

You need to make sure that this minimal submission works before proceeding.
The logs of the entrypoint are only shown in case there was an error (design from pyxis).
(A current workaround runs the entrypoint as a script at the start instead of as an entrypoint)

If the entrypoint fails the installation of your project, you can resubmit your job with `export SKIP_INSTALL_PROJECT=1`
which will skip the installation step then you can replay the installation manually in the container to debug it.

## Use cases

The basic configuration for the project's environment is now set up.
You can follow the remaining sections below to see how to run unattended jobs and set up remote development.
After that, return to the root README for the rest of the instructions to run our experiments.


### Running unattended jobs

By performing the above first steps, you should have all the required setup to run unattended jobs.
The main difference is that the unattended job is run with `sbatch`.
An example of an unattended job can be found in `submit-scripts/unattended.sh` to run with `sbatch`.
Note the emphasis on having a frozen copy `run` of the repository for running unattended jobs.

### Weights&Biases

Your W&B API key should be exposed as the `WANDB_API_KEY` environment variable.
You can export it or if you're sharing the script with others export a location to a file containing it with
`export WANDB_API_KEY_FILE_AT` and let the template handle it.

E.g.,

```bash
echo <my-wandb-api-key> > $HOME/.wandb-api-key
chmod 600 $HOME/.wandb-api-key
```

Then `export WANDB_API_KEY_FILE_AT=$HOME/.wandb-api-key` in the submit script.

### Remote development

This would be the typical use case for a researcher at CLAIRE using the cluster as their daily driver to do
development, testing, and debugging.
Your job would be running a remote IDE/code editor on the cluster, and you would only have a lightweight local client
running on your laptop.

The entrypoint will start an ssh server and a remote development server for your preferred IDE/code editor
when you set some environment variables.
An example of an interactive job submission can be found in `submit-scripts/remote-development.sh`
to run with `sbatch`.

Below, we list and describe in more detail the tools and IDEs supported for remote development.

### SSH Configuration (Necessary for PyCharm and VS Code)

Your job will open an ssh server when you set the environment variable `SSH_SERVER=1`.
You also have to mount the authorized keys file from your home directory to the container (done in the example).
The SSH connection is necessary for some remote IDEs like PyCharm to work and can be beneficial
for other things like ssh key forwarding.
The ssh server is configured to run on port 2223 of the container.

With the ssh connection, you can forward the ssh keys on your local machine (that you use for GitHub, etc.)
on the remote server.
This allows using the ssh keys on the remote server without having to copy them there.

For that, you need three things: an ssh agent running on your local machine, the key added to the agent,
and a configuration file saying that the agent should be used with the ssh connection to SCITAS.
GitHub provides a guide for that
[here (look at the troubleshooting section too)](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding).

Use the following configuration in your local `~/.ssh/config`

```bash
Host todi
    HostName todi.cscs.ch
    User smoalla
    ProxyJump ela
    ForwardAgent yes

# EDIT THIS HOSTNAME WITH EVERY NEW JOB
Host todi-job
    HostName nid005105
    User smoalla
    ProxyJump todi
    StrictHostKeyChecking no
	  UserKnownHostsFile=/dev/null
	  ForwardAgent yes

Host todi-container
    HostName localhost
    ProxyJump todi-job
    Port 2223
    User smoalla
	  StrictHostKeyChecking no
	  UserKnownHostsFile=/dev/null
	  ForwardAgent yes
```

The `StrictHostKeyChecking no` and `UserKnownHostsFile=/dev/null` allow bypass checking the identity
of the host [(ref)](https://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html)
which keeps changing every time a job is scheduled,
so that you don't have to reset it each time.

With this config you can then connect to your container with `ssh kuma-container`.

**Limitations**

Note that an ssh connection to the container is not like executing a shell on the container.
In particular, the following limitations apply:

- environment variables in the image sent to the entrypoint of the container and any command exec'ed in it
  are not available in ssh connections.
  There is a workaround for that in `entrypoints/remote-development-setup.sh` when opening an ssh server
  which should work for most cases, but you may still want to adapt it to your needs.

### Git config

You can persist your Git config (username, email, etc.) by mounting it in the container.
This is done in the examples.

E.g., create your config in your home directory with

```bash
cat >$HOME/.gitconfig <<EOL
[user]
        email = your@email
        name = Your Name
[core]
        filemode = false
EOL
```

### PyCharm Professional

We support the [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html)
feature of PyCharm that runs a remote IDE in the container.

The first time connecting you will have to install the IDE in the server in a location mounted from `/scratch` so
that is stored for future use.
After that, or if you already have the IDE stored in `/scratch` from a previous project,
the template will start the IDE on its own at the container creation,
and you will be able to directly connect to it from the JetBrains Gateway client on your local machine.

**Preliminaries: saving the project IDE configuration**

The remote IDE stores its configuration and cache (e.g., the interpreters you set up, memory requirements, etc.)
in `~/.config/JetBrains/RemoteDev-PY/...`, `~/.cache/JetBrains/RemoteDev-PY/...`, and other directories.

To have it preserved between different dev containers, you should specify the `JETBRAINS_SERVER_AT` env variable
with your submit command as shown in the examples in `submit-scripts/remote-development.sh`.
The template will use it to store the IDE configuration and cache in a separate directory
per project (defined by its $PROJECT_ROOT_AT).
All the directories will be created automatically.

**First time only (if you don't have the IDE stored from another project), or if you want to update the IDE.**

1. Submit your job as in the example `submit-scripts/remote-development.sh` and in particular edit the environment
   variables
    - `JETBRAINS_SERVER_AT`: set it to the `jetbrains-server` directory described above.
    - `PYCHARM_IDE_AT`: don't include it as IDE is not installed yet.
2. Enable port forwarding for the SSH port.
3. Then follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway) and
   install the IDE in your `${JETBRAINS_SERVER_AT}/dist`
   (something like `/scratch/moalla/jetbrains-server/dist`)
   not in its default location **(use the small "installation options..." link)**.
   For the project directory, it should be in the same location where it was mounted (`${PROJECT_ROOT_AT}`,
   something like `/scratch/moalla/template-project-name/dev`).

When in the container, locate the name of the PyCharm IDE installed.
It will be at
```bash
ls ${JETBRAINS_SERVER_AT}/dist
# Outputs something like e632f2156c14a_pycharm-professional-2024.1.4
```
The name of this directory will be what you should set the `PYCHARM_IDE_AT` variable to in the next submissions
so that it starts automatically.
```bash
PYCHARM_IDE_AT=744eea3d4045b_pycharm-professional-2024.1.6-aarch64
```

**When you have the IDE in the storage**
You can find an example in `submit-scripts/remote-development.sh`.

1. Same as above, but set the environment variable `PYCHARM_IDE_AT` to the directory containing the IDE binaries.
   Your IDE will start running with your container.
2. Enable port forwarding for the SSH port.
3. Open JetBrains Gateway, your project should already be present in the list of projects and be running.


**Configuration**:

* PyCharm's default terminal is bash. Change it to zsh in the Settings -> Tools -> Terminal.
* When running Run/Debug configurations, set your working directory the project root (`$PROJECT_ROOT_AT`), not the script's directory.
* Your interpreter will be
  * the system Python `/usr/bin/python` with the `from-python` option.
  * the Python in your conda environment with the `from-scratch` option, with the conda binary found at `/opt/conda/condabin/conda`.

**Limitations:**

- The terminal in PyCharm opens ssh connections to the container,
  so the workaround (and its limitations) in the ssh section apply.
  If needed, you could just open a separate terminal on your local machine
  and directly exec a shell into the container.
- It's not clear which environment variables are passed to the programs run from the IDE like the debugger.
  So far, it seems like the SSH env variables workaround works fine for this.
- Support for programs with graphical interfaces (i.g. forwarding their interface) has not been tested yet.

### VSCode

We support the [Remote Development using SSH ](https://code.visualstudio.com/docs/remote/ssh)
feature of VS code that runs a remote IDE in the container via SSH.

**Preliminaries: saving the IDE configuration**

The remote IDE stores its configuration (e.g., the extensions you set up) in `~/.vscode-server`.
To have it preserved between different dev containers, you should specify the
`VSCODE_SERVER_AT` env variable with your submit command
as shown in the examples in `submit-scripts/remote-development.sh`.
The template will use it to store the IDE configuration and cache in a separate directory
per project (defined by its $PROJECT_ROOT_AT).
All the directories will be created automatically.

**ssh configuration**

VS Code takes ssh configuration from files.
Follow the steps in the [SSH configuration section](#ssh-configuration-necessary-for-pycharm-and-vs-code)
to set up your ssh config file.

**Connecting VS Code to the container**:

1. In your submit command, set the environment variables for
    - Opening an ssh server `SSH_SERVER=1`.
    - preserving your config `VSCODE_SERVER_AT`.
2. Enable port forwarding for the SSH connection.
3. Have the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
   extension on your local VS Code.
4. Connect to the ssh host following the
   steps [here](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host).

The directory to add to your VS Code workspace should be the same as the one specified in the `PROJECT_ROOT_AT`.

**Limitations**

- The terminal in VS Code opens ssh connections to the container,
  so the workaround (and its limitations) in the ssh section apply.
  If needed, you could just open a separate terminal on your local machine
  and directly exec a shell into the container.
- Support for programs with graphical interfaces (i.g. forwarding their interface) has not been tested yet.

### JupyterLab (TODO)

### Examples

We provide examples of how to use the template in the `submit-scripts` directory.

### Troubleshooting
