# Guide for using the template with the EPFL SCITAS clusters (Kuma, Izar)

## Overview

At this point, you should have the runtime image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL SCITAS clusters supporting containers (Kuma, Izar)
and use it for

1. Remote development.
2. Running unattended jobs.

## Prerequisites

**SCITAS and Slurm**:

1. You should have access to the SCITAS clusters using containers (Kuma, Izar).
2. You should have some knowledge of Slurm.

CLAIRE lab members can refer to our internal documentation on using the SCITAS clusters
[here](https://prickly-lip-484.notion.site/Compute-and-Storage-CLAIRE-91b4eddcc16c4a95a5ab32a83f3a8294#1402ae1961ac4b3e86a6a3ee2d8602aa).

## First steps

### Getting your image on the SCITAS clusters

You only need to pull the generic image as SCITAS mounts namespaces to the containers.

All the commands should be run on the SCITAS clusters.
```bash
ssh izar
# or
ssh kuma
```
Create an enroot config file in your home directory on the cluster if you don't have one yet.
It will store your credentials for the registries.
```bash
export ENROOT_CONFIG_PATH=$HOME/.config/enroot/.credentials
mkdir -p $(dirname $ENROOT_CONFIG_PATH)
touch $ENROOT_CONFIG_PATH
# Make sur the file is only readable by you
chmod 600 $ENROOT_CONFIG_PATH
```
Write the following to the file.
```bash
# E.g. vim $ENROOT_CONFIG_PATH
machine ic-registry.epfl.ch login <username> password <password>
machine registry.rcp.epfl.ch login <username> password <password>
```

Optionally if you want to use Apptainer
```bash
apptainer registry login --username <username> docker://registry.rcp.epfl.ch
apptainer registry login --username <username> docker://ic-registry.epfl.ch
```

Then you can pull your image with
```bash
# On Izar
SCRATCH=/scratch/izar/$USER
# On Kuma
SCRATCH=/scratch/$USER
# Make a directory where you store your images
# Add it to your bashrc as it'll be used often
CONTAINER_IMAGES=$SCRATCH/container-images
mkdir -p $CONTAINER_IMAGES

# Pull the generic image (with tagged with root)
# E.g.,
cd $CONTAINER_IMAGES
# Don't do this on a login node.
# Replace with your image name

srun --ntasks=1 --cpus-per-task=32 --partition h100 --time=0:30:00 \
enroot import docker://registry.rcp.epfl.ch#claire/moalla/template-project-name:amd64-cuda-root-latest
# This will create a squashfs file that you'll use to start your jobs.
```

Optionally if you want to use Apptainer
```bash
# Takes ages to convert to sif.
# Don't do this on a login node.
# In a tmux shell ideally.
srun --ntasks=1 --cpus-per-task=32 --partition h100 --time=1:00:00 \
apptainer pull docker://registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-root-latest
```

### Clone your repository in your home directory

We strongly suggest having two instances of your project repository.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

The outputs and data directories of those two instances will be symlinked to the scratch storage
and will be shared anyway.
This guide includes the steps to do it, and there are general details in `data/README.md` and `outputs/README.md`.

```bash
# SSH to a cluster.
ssh kuma
mkdir -p $HOME/projects/template-project-name
cd $HOME/projects/template-project-name
git clone <git SSH URL> dev
git clone <git SSH URL> run
```

The rest of the instructions should be performed on the cluster from the dev instance of the project.
```bash
cd dev
# It may also be useful to open a remote code editor on a login node to view the project. (The remote development will happen in another IDE in the container.)
# Push what you did on your local machine so far (change project name etc) and pull it on the cluster.
git pull
cd installation/docker-amd64-cuda
```

### Note about the examples

The example files were made with username `moalla` and lab-name `claire`.
Adapt them accordingly to your username and lab name.
Run
```bash
# From the cluster this time.
./template.sh env
# Edit the .env file with your lab name (you can ignore the rest).
./template.sh get_scitas_scripts
```
to get a copy of the examples in this guide with your username, lab name, etc.
They will be in `./EPFL-SCITAS-setup/submit-scripts`.

### A quick test to understand how the template works

Adapt the `submit-scripts/minimal.sh` with the name of your image and your cluster storage setup.

The submission script gives two examples of how to run containers on SCITAS.
Either with [`enroot`](https://github.com/NVIDIA/enroo)
and the [`pyxis`](https://github.com/NVIDIA/pyxis) plugin directly integrated in `srun`,
or with `apptainer` inside tasks as a separate command.
We recommend using Pyxis+enroot as it allows more remote development tools to be used.

Run the script to see how the template works.
```bash
cd installation/docker-amd64-cuda/EPFL-SCITAS-setup/submit-scripts
bash minimal.sh
```

When the container starts, its entrypoint does the following:

- It runs the entrypoint of the base image if you specified it in the `compose-base.yaml` file.
- It expects you specify `PROJECT_ROOT_AT=<location to your project (dev or run)>`.
  and `PROJECT_ROOT_AT` to be the working directory of the container.
  Otherwise, it will issue a warning and set it to the default working directory of the container.
- It then tries to install the project in editable mode.
  This is a lightweight installation that allows to avoid all the hacky import path manipulations.
  (This will be skipped if `PROJECT_ROOT_AT` has not been specified or if you specify `SKIP_INSTALL_PROJECT=1`.)
- It also handles all the remote development setups (VS Code, Cursor, PyCharm, Jupyter, ...)
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

### SSH Configuration (Necessary for PyCharm, VS Code, and Cursor)

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
Host kuma
    HostName kuma.hpc.epfl.ch
    User moalla
    ForwardAgent yes

# EDIT THIS HOSTNAME WITH EVERY NEW JOB
Host kuma-job
    HostName kh021
    User moalla
    ProxyJump kuma
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    ForwardAgent yes

Host kuma-container
    HostName localhost
    ProxyJump kuma-job
    Port 2223
    User moalla
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    ForwardAgent yes
```
To update the hostname of the `clariden-job` you can add this to your `~/.zshrc` on macOS for example:

```bash
# Tested on macos with zsh
function update-ssh-config() {
  local config_file="$HOME/.ssh/config"  # Adjust this path if needed
  local host="$1"
  local new_hostname="$2"

  if [[ -z "$host" || -z "$new_hostname" ]]; then
    echo "Usage: update-ssh-config <host> <new-hostname>"
    return 1
  fi

  sed -i '' '/Host '"$host"'/,/Host / s/^[[:space:]]*HostName.*/    HostName '"$new_hostname"'/' "$config_file"
  echo "Updated HostName for '${host}' to '${new_hostname}' in ~/.ssh/config"
}
```

The `StrictHostKeyChecking no` and `UserKnownHostsFile=/dev/null` allow bypass checking the identity
of the host [(ref)](https://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html)
which keeps changing every time a job is scheduled,
so that you don't have to reset it each time.

With this config you can then connect to your container with `ssh clariden-container`.

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

The first time connecting you will have to install the IDE in the server in a location mounted in the container
that is stored for future use (somewhere in your `$HOME` directory).
After that, or if you already have the IDE stored in from a previous project,
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

1. `mkdir $HOME/jetbrains-server`
2. Submit your job as in the example `submit-scripts/remote-development.sh` and in particular edit the environment
   variables
    - `JETBRAINS_SERVER_AT`: set it to the `jetbrains-server` directory described above.
    - `PYCHARM_IDE_AT`: don't include it as IDE is not installed yet.
   And add `JETBRAINS_SERVER_AT` in the `--container-mounts`
3. Then follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway) and
   install the IDE in your `${JETBRAINS_SERVER_AT}/dist`
   (something like `/users/smoalla/jetbrains-server/dist`)
   not in its default location **(use the small "installation options..." link)**.
   For the project directory, it should be in the same location where it was mounted (`${PROJECT_ROOT_AT}`,
   something like `/users/smoalla/projects/template-project-name/dev`).

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

### VSCode / Cursor

We support the [Remote Development using SSH ](https://code.visualstudio.com/docs/remote/ssh)
feature of VS code that runs a remote IDE in the container via SSH. To set this up for Cursor, simply replace `VSCODE` by `CURSOR` and `vscode` by `cursor` in all instructions below. For example, `VSCODE_SERVER_AT` becomes `CURSOR_SERVER_AT`, and `~/.vscode-server` becomes `~/.cursor-server`.

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

1. `mkdir $HOME/vscode-server`
2. In your submit command, set the environment variables for
    - Opening an ssh server `SSH_SERVER=1`.
    - preserving your config `VSCODE_SERVER_AT`.
   And add `VSCODE_SERVER_AT` in the `--container-mounts`.
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
