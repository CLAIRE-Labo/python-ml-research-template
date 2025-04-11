# Guide for using the template with the EPFL IC and RCP Run:ai clusters

## Overview

At this point, you should have the runtime image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL IC and RCP Run:ai clusters and use it for:

1. Remote development. (At CLAIRE, we use the Run:ai platform as our daily driver.)
2. Running unattended jobs.

Using the image on HaaS machines falls into the public instructions
using the local deployment option with Docker Compose service and is covered by the
instructions in the `installation/docker-amd64-cuda/README.md` file.

## Prerequisites

**Run:ai**:

1. You should have access to a Run:ai project and have some knowledge of the Run:ai platform, e.g.,
   know the commands to submit jobs and check their status.
2. You should have one or more PVC(s) (Persistent Volume Claim) connecting some persistent storage
   to your Run:ai jobs, typically your lab's shared storage.
   (E.g. `runai-claire-gaspar-scratch`, you can run `kubectl get pvc` to list them).
3. You should have access to a project on the [IC](https://ic-registry.epfl.ch/) or [RCP](https://registry.rcp.epfl.ch/)
   image registries
   and should be logged in to them (`docker login <registry>`).

EPIC provides an introduction to these tools [here](https://epic-guide.github.io/tools/ic-compute-storage).
We also have a guide at CLAIRE which you can get inspiration from
[here](https://prickly-lip-484.notion.site/Compute-and-Storage-CLAIRE-91b4eddcc16c4a95a5ab32a83f3a8294#1402ae1961ac4b3e86a6a3ee2d8602aa).

## First steps

### Note about the examples

The examples in this README were made with username `moalla` and lab-name `claire`.
Adapt them accordingly to your username and lab name.
Run
```bash
./template.sh get_runai_scripts
```
to get a copy of the examples in this guide with your username, lab name, etc.
They will be in `.EPFL-runai-setup/submit-scripts`.

### Clone your repository in your PVC / shared storage

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

You can still have the outputs and data directories of those two instances shared.
This can be done by creating symlinks between them, in the same the way you can read data from another PVC,
say a shared PVC that has model weights, etc. All of this is described in the
`data/README.md` and `outputs/README.md` files of the template and can be done later.

Follow the steps below to clone your repository in your PVCs / shared storage.

Typically the storage underlying your PVC is also mounted on a permanent machine that you can access.
CLAIRE members can use the `claire-build-machine` for this to access `claire-rcp-scratch`.
RCP also provides a shared jump host `haas001.rcp.epfl.ch` that mounts most lab's shared storage.

Setup your SSH configuration so that your keys are forwarded during your ssh connection to machine
so that you can clone your repository easily.
For CLAIRE members you should have the `claire-build-machine` already setup.
For other labs you can copy the config example below for `haas001.rcp.epfl.ch`.

```bash
# You need three things for your ssh keys to be forwarded during a connection:
# an ssh agent running on your local machine,
# the key added to the agent,
# and a configuration file saying that the agent should be used with connection.
# GitHub provides a guide for that (look at the troubleshooting section too)
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding
# and for the ssh config file you can use the following:
Host rcp-haas
	HostName haas001.rcp.epfl.ch
	User YOUR-GASPAR
	ForwardAgent yes
```

SSH to the machine and clone your repository in your PVC / shared storage.
   (Remember to push the changes you made on your local machine after initializing the template,
   to have the latest state of your repo.)
   ```bash
   # Somewhere in your PVC, say your personal directory there.
   mkdir template-project-name
   git clone <git SSH URL> template-project-name/dev
   git clone <git SSH URL> template-project-name/run
   ```

   We also recommend that you make Git ignore the executable bit as the repo is moved across filesystems.
   You can do so by running `git config core.filemode false` in both repositories.

   ```bash
   cd template-project-name/dev && git config core.filemode false
   cd ../run && git config core.filemode false
   ```

### A quick test to understand how the template works

Adapt the `submit-scripts/minimal.sh` with the name of your image, your PVC,
and the correct path to your project in the PVC.

When the container starts, its entrypoint does the following:

- It runs the entrypoint of the base image if you specified it in the `compose-base.yaml` file.
- It expects you specify `PROJECT_ROOT_AT=<location to your project in the PVC>`
  and to set `PROJECT_ROOT_AT` as the working directory of the container
  and installs the project found at `PROJECT_ROOT_AT` in editable mode.
  This is a lightweight installation that allows to avoid all the hacky import path manipulations.
  (You can skip this if you have a different project structure,
  e.g.,
  just copied the installation directory of the template by not specifying `PROJECT_ROOT_AT`).
- It also handles all the remote development setups (VS Code, Cursor, PyCharm, Jupyter, ...)
  that you specify with environment variables.
  These are described in the later sections of this README.
- Finally, it executes a provided command (e.g. `sleep infinity`), otherwise by default will run a shell and stop.
  It runs this command with PID 1 so that it can receive signals from the cluster and gracefully stop when preempted.
  You should not have to override the entrypoint, i.e., using `--command` flag with `runai submit`
  unless you are debugging the entrypoint itself.

You need to make sure that this minimal submission works before proceeding.
You can check the logs of the container with `runai logs example-minimal` to see if everything is working as expected.
You should expect to see something like:

```text
$ runai logs example-minimal
...
[TEMPLATE INFO] PROJECT_ROOT_AT is set to /claire-rcp-scratch/home/moalla/template-project-name/dev.
[TEMPLATE INFO] Expecting workdir to be /claire-rcp-scratch/home/moalla/template-project-name/dev.
[TEMPLATE INFO] Installing the project with pip.
[TEMPLATE INFO] Expecting /claire-rcp-scratch/home/moalla/template-project-name/dev to be a Python project.
[TEMPLATE INFO] To skip this installation use the env variable SKIP_INSTALL_PROJECT=1.
Obtaining file:///claire-rcp-scratch/home/moalla/template-project-name/dev
  Installing build dependencies: started
  ...
  Building editable for template-project-name (pyproject.toml): started
  ...
Successfully built template-project-name
Installing collected packages: template-project-name
Successfully installed template-project-name-0.0.1
[TEMPLATE INFO] Testing that the package can be imported.
[TEMPLATE INFO] Package imported successfully.
[TEMPLATE INFO] Executing the command sleep infinity
````

You can then open a shell in the container and check that everything is working as expected:

```bash
runai exec -it example-minimal zsh
```

If the entrypoint fails the installation of your project, you can resubmit your job with `-e SKIP_INSTALL_PROJECT=1`
which will skip the installation step then you can replay the installation manually in the container to debug it.

## Use cases

The basic configuration for the project's environment is now set up.
You can follow the remaining sections below to see how to run unattended jobs and set up remote development.
After that, return to the root README for the rest of the instructions to run our experiments.


### Running unattended jobs

By performing the above first steps, you should have all the required setup to run unattended jobs.
An example of an unattended job can be found in `submit-scripts/unattended.sh`.
Note the emphasis on having a frozen copy `run` of the repository for running unattended jobs.


### Run:ai selectors

Different clusters have different names for node pools and options to enable `sudo` usage etc.
Refer to the `submit-scripts` for the main options, otherwise to the clusters' respective documentation.

### Weights&Biases

Your W&B API key should be exposed as the `WANDB_API_KEY` environment variable.
Run:ai doesn't support Kubernetes secrets yet, and you don't want to pass it as a clear environment variable
(visible in the Run:ai dashboard),
so an alternative is to have it in your PVC and pass it with the
`-e WANDB_API_KEY_FILE_AT` environment variable in your `runai submit` command and let the template handle it.

E.g.,

```bash

# In my PVC.
# <my-wandb-api-key>
echo <my-wandb-api-key> > /claire-rcp-scratch/home/moalla/.wandb-api-key
```

Then specify `-e WANDB_API_KEY_FILE_AT=/claire-rcp-scratch/home/moalla/.wandb-api-key` in my `runai submit` command.

### HuggingFace

Same idea as for W&B, you should have your Hugging Face API key in your PVC and pass it with the
`-e HF_TOKEN_AT` environment variable in your `runai submit` command.

E.g.,

```bash

# In my PVC
echo <my-hf-api-key> > /claire-rcp-scratch/home/moalla/.hf-token
```

Then specify
`-e HF_TOKEN_AT=/claire-rcp-scratch/home/moalla/.hf-token` in my `runai submit` command.


### Remote development

This would be the typical use case for a user at CLAIRE using the Run:ai cluster as their daily driver to do
development, testing, and debugging.
Your job would be running a remote IDE/code editor on the cluster, and you would only have a lightweight local client
running on your laptop.

The entrypoint will start an ssh server and a remote development server for your preferred IDE/code editor
when you set some environment variables.
An example of an interactive job submission can be found in `submit-scripts/remote-development.sh`.

Below, we list and describe in more detail the tools and IDEs supported for remote development.

### SSH Configuration (Necessary for PyCharm, VS Code, and Cursor)

Your job will open an ssh server when you set the environment variable `SSH_SERVER=1`.
This is necessary for some remote IDEs like PyCharm to work and can be beneficial
for other things like ssh key forwarding.

The ssh server is configured to run on port 2223 of the container.
You can forward a local port on your machine to this port on the container.

When your container is up, run

```bash
# Here 2222 on the local machine is forwarded to 2223 on the pod.
# You can change the local port number to another port number.
kubectl get pods
kubectl port-forward <pod-name> 2222:2223
```

You can then ssh to your container by ssh-ing to that port on your local machine.
Connect with the user and password you specified in your `.env` file when you built the image.

```bash
# ssh to local machine is forwarded to the pod.
ssh -p 2222 <username>@localhost
```

As the container will each time be on a different machine, the ssh key for the remote server has to be reset or not stored..
This is done for you in the ssh config below. If you face issues you can reset the key with:

```bash
ssh-keygen -R '[localhost]:2222'
```

With the ssh connection, you can forward the ssh keys on your local machine (that you use for GitHub, etc.)
on the remote server.
This allows using the ssh keys on the remote server without having to copy them there.
(The alternative would be to have them as Kubernetes secrets,
but Run:ai doesn't support that yet with its submit command.)

For that, you need three things: an ssh agent running on your local machine, the key added to the agent,
and a configuration file saying that the agent should be used with the Run:ai job.
GitHub provides a guide for that
[here (look at the troubleshooting section too)](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding)
and for the ssh config file you can use the following:

```bash
Host local2222
	HostName 127.0.0.1
	User <username>
	Port 2222
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
	ForwardAgent yes
# If you open multiple projects at the same time, you can forward each of them to a different port.
# And have two entries in your ssh config file.
```

The `StrictHostKeyChecking no` and `UserKnownHostsFile=/dev/null` allow bypass checking the identity
of the host [(ref)](https://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html)
which keeps changing every time a job is scheduled,
so that you don't have to reset it each time.

With this config you can then simply connect to your container with `ssh local2222` when the port 2222 is forwarded.

**Limitations**

Note that an ssh connection to the container is not like executing a shell on the container.
In particular, the following limitations apply:

- environment variables in the image sent to the entrypoint of the container and any command exec'ed in it
  are not available in ssh connections.
  There is a workaround for that in `entrypoints/remote-development-setup.sh` when opening an ssh server
  which should work for most cases, but you may still want to adapt it to your needs.

### Git config

You can persist your Git config (username, email, etc.) by having it in your PVC and passing its location
with the `GIT_CONFIG_AT` environment variable.

E.g., create your config in your PVC with

```bash
# In my PVC.
cat >/claire-rcp-scratch/home/moalla/remote-development/gitconfig <<EOL
[user]
        email = your@email
        name = Your Name
[core]
        filemode = false
EOL
```

Then specify something like `-e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig`
in your `runai submit` command.

### PyCharm Professional

We support the [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html)
feature of PyCharm that runs a remote IDE in the container.

The first time connecting you will have to install the IDE in the server in a location mounted from your PVC so
that is stored for future use.
After that, or if you already have the IDE stored in your PVC from a previous project,
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
   (something like `/claire-rcp-scratch/home/moalla/remote-development/jetbrains-server/dist`)
   not in its default location **(use the small "installation options..." link)**.
   For the project directory, it should be in the same location as your PVC (`${PROJECT_ROOT_AT}`.
   something like `/claire-rcp-scratch/home/moalla/template-project-name/dev`).

When in the container, locate the name of the PyCharm IDE installed.
It will be at
```bash
ls ${JETBRAINS_SERVER_AT}/dist
# Outputs something like e632f2156c14a_pycharm-professional-2024.1.4
```
The name of this directory will be what you should set the `PYCHARM_IDE_AT` variable to in the next submissions
so that it starts automatically.
```bash
PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4
```

**When you have the IDE in the PVC**
You can find an example in `submit-scripts/remote-development.sh`.

1. Same as above, but set the environment variable `PYCHARM_IDE_AT` to the directory containing the IDE binaries.
   Your IDE will start running with your container.
2. Enable port forwarding for the SSH port.
3. Open JetBrains Gateway, your project should already be present in the list of projects and be running.
4. Otherwise, your container prints a link to the IDE that you can find it its logs.
   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
    Gateway link: jetbrains-gateway://connect#idePath=%2Fclaire-rcp-scratch%2Fhome%2Fmoalla%2Fremote-development%2Fpycharm&projectPath=%2Fclaire-rcp-scratch%2Fhome%2Fmoalla%2Ftemplate-project-name%2Fdev&host=127.0.0.1&port=2223&user=moalla&type=ssh&deploy=false&newUi=true
    ```
   Use it in Gateway to connect to the IDE.

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
to set up your ssh config file for runai jobs.

**Connecting VS Code to the container**:

1. In your `runai submit` command, set the environment variables for
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

### JupyterLab

If you have `jupyterlab` in your dependencies, then the template can open a Jupyter Lab server for you when
the container starts.

To do so, you need to:

1. Set the `JUPYTER_SERVER=1` environment variable in your `runai submit` command.
   You can find an example in `submit-scripts/remote-development.sh`.

   A Jupyter server will start running with your container. It will print a link to the container logs.

   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
   [C 2023-04-26 17:17:03.072 ServerApp]

    To access the server, open this file in a browser:
        ...
    Or copy and paste this URL:
        http://hostname:8887/?token=1098cadee3ac0c48e0b0a3bf012f8f06bb0d56a6cde7d128
   ```

2. Forward the port `8887` on your local machine to the port `8887` on the container.
   ```bash
   kubectl port-forward <pod-name> 8887:8887
   ```

3. Open the link in your browser, replacing `hostname` with `localhost`.

**Note:**

Development on Jupyter notebooks can be very useful, e.g., for quick iterations, plotting, etc., however,
it can very easily facilitate bad practices, such as debugging with print statements, prevalence of global variables,
relying on long-living kernel state, and hinder the reproducibility work.
We strongly recommend using an IDE with a proper debugger for development, which would fill the need for quick
iterations, and only use Jupyter notebooks for plotting results
(where data is properly loaded from the output of a training script).

**Limitations:**

- We have limited usage of Jupyter so limitations are not known yet.

### Examples

We provide examples of how to use the template in the `submit-scripts` directory.
We use `submit` commands and not YAML files to specify job configurations because the Run:ai API for kubernetes
resources keeps changing and is not stable yet.

### Troubleshooting
