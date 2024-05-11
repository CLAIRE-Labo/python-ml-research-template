# Guide for using the template with the EPFL IC and RCP Run:ai clusters

## Overview

At this point, you should have runtime and development images that can be deployed on multiple platforms.
This guide will show you how to deploy your images on the EPFL IC and RCP Run:ai clusters and use them for:

1. Remote development. (At CLAIRE, we use the Run:ai platform as our daily driver.)
2. Running unattended jobs.

Using the image on HaaS machines falls into the public instructions
using the local deployment option with Docker Compose service and is covered by the
instructions in the `installation/docker-amd64-cuda/README.md` file.

## Prerequisites

**Docker image**:

You should be able to run your Docker images locally
(e.g., on the machine you built it, or for CLAIRE with the remote Docker Engine on our `claire-build-machine`).
It will be hard to debug your image on Run:ai if you can't even run it locally.
The simple checks below will be enough.

```bash
# Check all your dependencies are there.
./template.sh list_env

# Get a shell and check manually other things.
# This will only contain the environment and not the project code.
# Project code can be debugged on the cluster directly.
./template.sh empty_interactive
```

**Run:ai**:

1. You should have access to a Run:ai project and have minimum knowledge of the Run:ai platform, e.g.,
   know the commands to submit jobs and check their status.
2. You should have one or more PVC(s) (Persistent Volume Claim) connecting some persistent storage
   to your Run:ai jobs, typically your lab's shared storage.
   (E.g. `runai-claire-gaspar-scratch`, you can run `kubectl get pvc` to list them).
3. You should have access to a project on the [IC](https://ic-registry.epfl.ch/) or [RCP](https://registry.rcp.epfl.ch/)
   image registries
   and should be logged in (`docker login <registry>`).

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

### Push your image to the RCP or IC Docker registry

The following will push the generic and user-configured runtime and development images.

- `LAB_NAME/USR/PROJECT_NAME:PLATFORM-run-latest-root`
- `LAB_NAME/USR/PROJECT_NAME:PLATFORM-dev-latest-root`
- `LAB_NAME/USR/PROJECT_NAME:PLATFORM-run-latest-USR`
- `LAB_NAME/USR/PROJECT_NAME:PLATFORM-dev-latest-USR`

It will also push them with the git commit hash as a tag if no new commit was made since the last build.
You can rebuild the images with `./template.sh build` to tag them with the latest commit hash.

```bash
./template.sh push IC
# Or/and (both clusters can read from both registries)
./template.sh push RCP
```

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Give the generic image name you just pushed
> (e.g., `ic-registry.epfl.ch/LAB_NAME/USR/PROJECT_NAME`)
> to your teammates so that they can directly build their user-configured images on top of it.
> Replace the _TODO ADD PULL_IMAGE_NAME_ in the `installation/docker-amd64-cuda/README` file with this name.

### Clone your repository in your PVCs

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

You can still have the outputs and data directories of those two instances shared.
This can be done by creating symlinks between them, the way you can read data from another PVC,
say a shared PVC that has model weights, etc. All of this is described in the
`data/README.md` and `outputs/README.md` files of the template and can be done later.

Follow the steps below to clone your repository in your PVCs.

If you have access to the storage underlying your PVC, you can skip step 1 and 2.
(E.g., CLAIRE members can use the `claire-build-machine` for this to access `claire-rcp-scratch`).
Otherwise, the template covers a deployment option that simply opens an ssh server
on your container without setting up the project,
forwards your ssh keys, and allows you to clone your repository on the container.

1. Submit your job in the same fashion as `submit-scripts/first-steps.sh`,
   specifying your image name, and the PVC where you'll put your code (typically the scratch one).
   Checking its logs will give:
   ```text
    $ runai logs example-first-steps
   ...
    [TEMPLATE INFO] Running entrypoint.sh
    [TEMPLATE WARNING] PROJECT_ROOT_AT is not set.
    [TEMPLATE WARNING] It is expected to point to the location of your mounted  project.
    [TEMPLATE WARNING] It has been defaulted to /workspace
    [TEMPLATE WARNING] The project installation will be skipped.
    [TEMPLATE INFO] The next commands (and all interactive shells) will be run from /workspace.
    [TEMPLATE INFO] Skipping the installation of the project.
    [TEMPLATE INFO] Configuring ssh server.
    [TEMPLATE INFO] Starting ssh server.
    [TEMPLATE INFO] Executing the command sleep infinity
   ```
   You can ignore the warning, as you skipped the installation of the project.
2. Follow the steps in the [SSH configuration section](#ssh-configuration-necessary-for-pycharm-and-vs-code)
   and ssh to your container.
3. Clone your repository in your PVC.
   (Remember to push the changes you made on your local machine after initializing the template,
   to have the latest state of your repo.)
   ```bash
   # Somewhere in your PVC, say your personal directory there.
   mkdir template-project-name
   git clone <HTTPS/SSH> template-project-name/dev
   git clone <HTTPS/SSH> template-project-name/run
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
- It expects you specify `PROJECT_ROOT_AT=<location to your project in the PVC>`.
  and will make `PROJECT_ROOT_AT` the working directory for the next commands and any interactive shell.
  Otherwise, it will issue a warning and set it to the default working directory of the container.
- It then tries to install the project in editable mode, assuming that it is in the working directory.
  This is a lightweight installation that allows to avoid all the hacky import path manipulations.
  (This will be skipped if `PROJECT_ROOT_AT` has not been specified or if you specify `SKIP_INSTALL_PROJECT=1`.)
- It also handles all the remote development setups (VS Code, Jupyter, ...) that you specify with environment variables.
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
[TEMPLATE INFO] Running entrypoint.sh
[TEMPLATE INFO] PROJECT_ROOT_AT is set to /claire-rcp-scratch/home/moalla/template-project-name/dev.
[TEMPLATE INFO] The next commands (and all interactive shells) will be run from /claire-rcp-scratch/home/moalla/template-project-name/dev.
[TEMPLATE INFO] Installing the project with pip.
[TEMPLATE INFO] Expecting /claire-rcp-scratch/home/moalla/template-project-name/dev to be a Python project.
[TEMPLATE INFO] To skip this installation use the env variable SKIP_INSTALL_PROJECT=1.
...
Obtaining file:///claire-rcp-scratch/home/moalla/template-project-name/dev
...
Building wheels for collected packages: template-project-name
...
Successfully built template-project-name
Installing collected packages: template-project-name
Successfully installed template-project-name-0.0.1
...
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

### Weights&Biases

Your W&B API key should be exposed as the `WANDB_API_KEY` environment variable.
Run:ai doesn't support Kubernetes secrets yet, and you don't want to pass it as a clear environment variable
(visible in the Run:ai dashboard),
so an alternative is to have it in your PVC and pass it with the
`-e WANDB_API_KEY_FILE_AT` environment variable in your `runai submit` command and let the template handle it.

E.g.,

```bash

# In my PVC.
echo <my-wandb-api-key> > /claire-rcp-scratch/home/moalla/.wandb_api_key
```

Then specify `-e WANDB_API_KEY_FILE_AT=/claire-rcp-scratch/home/moalla/.wandb_api_key` in my `runai submit` command.

### Remote development

This would be the typical use case for a researcher at CLAIRE using the Run:ai cluster as their daily driver to do
development, testing, and debugging.
Your job would be running a remote IDE/code editor on the cluster, and you would only have a lightweight local client
running on your laptop.

The entrypoint will start an ssh server and a remote development server for your preferred IDE/code editor
when you set some environment variables.
An example of an interactive job submission can be found in `submit-scripts/remote-development.sh`.

Below, we list and describe in more detail the tools and IDEs supported for remote development.

### SSH Configuration (Necessary for PyCharm and VS Code)

Your job will open an ssh server when you set the environment variable `SSH_SERVER=1`.
This is necessary for some remote IDEs like PyCharm to work and can be beneficial
for other things like ssh key forwarding.

The ssh server is configured to run on port 22 of the container.
You can forward a local port on your machine to this port on the container.

When your container is up, run

```bash
# Here 2222 on the local machine is forwarded to 22 on the pod.
# You can change the local port number to another port number.
kubectl get pods
kubectl port-forward <pod-name> 2222:22
```

You can then ssh to your container by ssh-ing to that port on your local machine.
Connect with the user and password you specified in your `.env` file when you built the image.

```bash
# ssh to local machine is forwarded to the pod.
ssh -p 2222 <username>@localhost
```

As the container will each time be on a different machine, you will have to reset the ssh key for the remote server.
You can do this with

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
Host runai
	HostName 127.0.0.1
	User <username>
	Port 2222
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
	ForwardAgent yes
```

The `StrictHostKeyChecking no` and `UserKnownHostsFile=/dev/null` allow bypass checking the identity
of the host [(ref)](https://linuxcommando.blogspot.com/2008/10/how-to-disable-ssh-host-key-checking.html)
which keeps changing every time a job is scheduled,
so that you don't have to reset it each time.

With this config you can then simply connect to your container with `ssh runai` when the port 2222 is forwarded.

**Limitations**

Note that an ssh connection to the container is not like executing a shell on the container.
In particular, the following limitations apply:

- environment variables in the image sent to the entrypoint of the container or any command exec'ed in it
  are not available in ssh connections.
  There is a workaround for that in `entrypoints/remote-development-steup.sh` when opening an ssh server
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

### PyCharm

We support the [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html)
feature of PyCharm that runs a remote IDE in the container.
We prefer this method to using the container as
a [remote interpreter](https://www.jetbrains.com/help/pycharm/configuring-remote-interpreters-via-ssh.html), as with the
latter, the code will have to be kept in sync between the container and your local machine,
creating a mismatch with the non-interactive way of running the template.

There are two main ways to use PyCharm Remote development with an ssh server (here, our container):

1. Using the JetBrains Gateway client to install the IDE in the server and connect to it.
2. The server has access to remote IDE binaries, starts the IDE on its own, and gives you a link to use with
   Gateway to directly connect to it.

The template supports both options.
We suggest using option 1 when you don't have access to the PyCharm remote IDE binaries for the first time.
Then settle with option 2 as it makes using Run:ai as your daily driver feel like just opening a local IDE.

For both options you will set your project directory on PyCharm
to be the same as the one specified in the `PROJECT_ROOT_AT`.

**Preliminaries: saving the project IDE configuration**

The remote IDE stores its configuration (e.g., the interpreters you set up, memory requirements, etc.)
in `~/.config/JetBrains/RemoteDev-PY/...` and its cache in `~/.cache/JetBrains/RemoteDev-PY/...`.
Every project location will have its own configuration and cache there.

To have it preserved between different dev containers, you should create a placeholder
directory in your PVC and the template will handle sym-linking it when the container starts.
You can put this directory in a place where you keep the remote development tools in your PVC.
(You can use the `minimal.sh` example to access your PVC.)

```
/claire-rcp-scrach/home/moalla/template-project-name
├── ...               # Other remote development tools.
└── pycharm-config    # To contain the config and cache of the IDE.
```

You should then specify the `PYCHARM_CONFIG_AT` env variable with your submit command to maintain
your IDE and project configurations.

**Option 1:**

1. Submit your job as in the example `submit-scripts/remote-development.sh` and in particular edit the environment
   variables
    - `PYCHARM_CONFIG_AT` by setting to the `pycharm-config` described above.
    - `PYCHARM_IDE_AT` by deleting it as the IDE will be installed after the container is run.
2. Enable port forwarding for the SSH port.
3. Then follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway).

You can then copy the directory containing the binaries `~/.cache/JetBrains/RemoteDev/dist/<some_pycharm_ide_version>`
to your PVC to use option 2.

```bash
# Example
cp -r ~/.cache/JetBrains/RemoteDev/dist/<some_pycharm_ide_version> /claire-rcp-scrach/home/moalla/remote-development/pycharm
```

**Option 2:**
You can find an example in `submit-scripts/remote-development.sh`.

1. Same as option 1, but set the environment variable `PYCHARM_IDE_AT` to the directory containing the IDE binaries.
   Your IDE will start running with your container.
   It will print a link to the IDE in the container logs.

   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
    Gateway link: jetbrains-gateway://connect#idePath=%2Fclaire-rcp-scratch%2Fhome%2Fmoalla%2Fremote-development%2Fpycharm&projectPath=%2Fclaire-rcp-scratch%2Fhome%2Fmoalla%2Ftemplate-project-name%2Fdev&host=127.0.0.1&port=2222&user=moalla&type=ssh&deploy=false&newUi=true
    ```
2. Enable port forwarding for the SSH port.
3. Use the Gateway link to connect to the remote IDE from a local JetBrains Gateway client as
   described [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#use_idea).
   Alternatively, you will also directly find the host on your list of Gateway connections.

**Configuration**:

* PyCharm's default terminal is bash. Change it to zsh in the Settings -> Tools -> Terminal.
* When running Run/Debug configurations, set your working directory the `PROJECT_ROOT_AT`, not the script's directory.
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

We support the [Remote Development using SSH ](https://code.visualstudio.com/docs/remote/ssh) feature of
VS code that runs a remote IDE in the container.

**Preliminaries: saving the IDE configuration**

The remote IDE stores its configuration (e.g., the extensions you set up) in `~/.vscode-server`.
To have it preserved between different dev containers, you should create a placeholder
directory in your PVC and the template will handle sym-linking it when the container starts.
You can put this directory in a place where you keep the remote development tools in your PVC.
(You can use the `minimal.sh` example to access your PVC.)

```
/claire-rcp-scratch/home/moalla/remote-development
├── ...            # Other remote development tools.
└── vscode-server  # To contain the IDE .vscode-server for the project.
```

You should then specify the `VSCODE_CONFIG_AT` env variable with your submit command to preserve
your IDE configuration.

**ssh configuration**

VS Code takes ssh configuration from files.
Follow the steps in the [SSH configuration section](#ssh-configuration-necessary-for-pycharm-and-vs-code)
to set up your ssh config file for runai jobs.

**Connecting VS Code to the container**:

1. In your `runai submit` command, set the environment variables for
    - Opening an ssh server `SSH_SERVER=1`.
    - preserving your config `VSCODE_CONFIG_AT`.
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
        http://hostname:8888/?token=1098cadee3ac0c48e0b0a3bf012f8f06bb0d56a6cde7d128
   ```

2. Forward the port `8888` on your local machine to the port `8888` on the container.
   ```bash
   kubectl port-forward <pod-name> 8888:8888
   ```

3. Open the link in your browser, replacing hostname with localhost.

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
