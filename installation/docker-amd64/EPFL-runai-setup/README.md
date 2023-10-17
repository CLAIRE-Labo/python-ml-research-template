# Guide for using the template with the EPFL IC and RCP Run:ai clusters

## Overview

At this point, you should have runtime and dev images that can be deployed on multiple platforms.
This guide will show you how to deploy your images on the EPFL IC and RCP Run:ai clusters and use them for:

1. Remote development. (At CLAIRE we use the Run:ai platform as our daily driver.)
2. Running unattended jobs.

Using the image on HaaS machines falls into the public instructions
using the local deployment option with Docker Compose service and is covered by the
instructions in the `installation/docker-amd64/README.md` file.

## Prerequisites

**Docker image**:

You should be able to run your Docker images locally (e.g. on the machine you built it, or for CLAIRE on our `claire-build-machine`).
It will be hard to debug your image on Run:ai if you can't even run it locally.
The simple checks below will be enough.
```bash
# Check all your dependencies are there.
./template list-env

# Get a shell and check manually other things.
# This will only contain the environment and not the project code.
# Project code can be debugged on the cluster directly.
./template empty-interactive
```

**Run:ai**:

1. You should have minimum knowledge of the Run:ai platform, e.g. know the commands to submit jobs and check their status.
2. You should have access to a project on the IC or RCP image registry and should be logged in.
   (CLAIRE members should use [ic-registry.epfl.ch/claire](https://ic-registry.epfl.ch/harbor/projects/113/summary))
3. You should have one or more PVC(s) (Persistent Volume Claim) connecting some persistent storage to the cluster, say your lab NFS. 
   (CLAIRE members should use `runai-claire-gaspar-scratch`).

EPIC provides an introduction to these tools [here](https://epic-guide.github.io/tools/ic-compute-storage).

## First steps

### Push your image to the RCP or IC Docker registry

The following will push 2 images with 2 tags each:
- `LAB_NAME/PROJECT_NAME/USR:latest-runtime`
- `LAB_NAME/PROJECT_NAME/USR:<commit-sha>-runtime`
- `LAB_NAME/PROJECT_NAME/USR:latest-dev`
- `LAB_NAME/PROJECT_NAME/USR:<commit-sha>-dev`

```bash
./template push IC
# Or (both clusters can read from both registries)
./template push RCP
```

### Clone your repository in your PVCs

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

In addition, if you have multiple PVCs with different performance characteristics,
you may want to put your data and outputs on a different PVC than your code.
This is straightforward with this template and is covered in the examples provided.

If you already have your repository in your PVC, e.g. because you have your NFS mounted on an ssh server that you use
for development,
you can skip step 1 and 2.
(E.g. CLAIRE members can use the `claire-build-machine` for this.)
Otherwise, the template covers a deployment options that simply opens an ssh server on your container without setting up
the project, forwards your ssh keys, and allows you to clone your repository on the container.

1. Submit your job in the same fashion as `submit-examples/first_steps.sh`,
   specifying your image name, and PVC(s).
   Checking its logs will give:
   ```bash
    $ runai logs example-first-steps
    Running entrypoint.sh
    [TEMPLATE INFO] Running entrypoint.sh
    [TEMPLATE INFO] Running EPFL Run:ai setup script.
    [TEMPLATE INFO] Entering EPFL Run:ai interactive startup.
    [TEMPLATE INFO] Configuring ssh server.
    [TEMPLATE INFO] SSH_ONLY mode enabled.
   ```
2. Follow the steps in the [SSH configuration section](#ssh-configuration) and ssh to your container.
3. Clone your repository in your PVCs. (Don't forget to push & pull the changes you did after initializing the
   template.)

   ```bash
   # Somewhere in your PVC.
   mkdir template-project-name
   git clone <repo-url> template-project-name/dev
   git clone <repo-url> template-project-name/run
   # cd dev && git config core.filemode false
   # cd run && git config core.filemode false
   ```
We also recommend that you make Git ignore the executable bit as the repo is moved across filesystems.
You can do so by running `git config core.filemode false` in both repositories.

### A quick test to understand how the template works

Adapt the `submit-examples/minimal.sh` with the name of your image, your PVC(s), and the correct paths to your project
in the PVC(s).

As in the example, when you specify the `EPFL_RUNAI=1` environment variable with your submit command,
the entrypoint of the container will run a setup script that:

- Creates symlinks to the relevant directories in your PVCs inside the `${PROJECT_ROOT}=/opt/project/` in the container.
  (This is a workaround as Run:ai does not support directly mounting subdirectories of PVCs)
- Installs the project in editable mode. This is a lightweight installation that allows you to edit the code
  on your local machine and have the changes reflected in the container.
- Executes a provided command (e.g. `sleep infinity`), otherwise by default will run a shell and stop.
  The command is given as a `CMD` directive to Docker, passed to the entrypoint, which will run it PID 1.
  You should not have to override the entrypoint itself, i.e. using `--command` flag with `runai submit`.

You need to make sure that this minimal submission works before proceeding.
You can check the logs of the container with `runai logs example-minimal` to see if everything is working as expected.
You should expect to see something like:

```bash
$ runai logs example-minimal
[TEMPLATE INFO] Running entrypoint.sh
[TEMPLATE INFO] Running EPFL Run:ai setup script.
[TEMPLATE INFO] Creating symlinks to directories in PVCs.
[TEMPLATE INFO] Sym-linked /opt/project/template-project-name to /claire-rcp-scratch/home/moalla/template-project-name/dev
[TEMPLATE INFO] Sym-linked /opt/project/data to /claire-rcp-scratch/home/moalla/template-project-name/dev/_data
[TEMPLATE INFO] Sym-linked /opt/project/outputs to /claire-rcp-scratch/home/moalla/template-project-name/dev/_outputs
[TEMPLATE INFO] Sym-linked /opt/project/wandb to /claire-rcp-scratch/home/moalla/template-project-name/dev/_wandb
[TEMPLATE INFO] Installing the project.
Obtaining file:///opt/project/template-project-name
  Installing build dependencies: started
  ...
Successfully installed template-project-name-0.0.1
[TEMPLATE INFO] Executing the command sleep infinity
````

You can then open a shell in the container and check that everything is working as expected:

```bash
runai exec -it example-minimal zsh
```

## Use cases

### Running unattended jobs

By performing the above first steps you should have all the required setup to run unattended jobs.
An example of an unattended job can be found in `submit-examples/unattended.sh`.
Note the emphasis on having a frozen copy of the repository for running unattended jobs.

### Remote development

This would be the typical use case for a researcher at CLAIRE using the Run:ai cluster as their daily driver to do
development, testing, and debugging.
Your job would be running a remote IDE/code editor on the cluster, and you would only have a lightweight local client
running on you laptop.

When you specify the additional environment variable with your submitted job `EPFL_RUNAI_INTERACTIVE=1`,
the entrypoint will run an additional setup script that can start an ssh server and a remote development server
for your preferred IDE/code editor.

You can configure this to your needs with environment variables sent with the `runai submit` command.
An example of an interactive job submission can be found in `submit-examples/remote_development.sh`.

Below, we list and describe in more detail the tools and IDEs supported for remote development.

### SSH Configuration - Necessary for PyCharm and VS Code

Your job will open an ssh server when you set the environment variable `SSH_SERVER=1`.

The ssh server is configured to run on port 22 of the container.
With Run:ai, you can forward a local port on your machine to this port on the container.

That is, when your container is up, run

```bash
# Here 2222 on the local machine is forwarded to 22 on the pod.
# You can change the local port number to another port number.
kubectl port-forward <pod-name> 2222:22
```

You can then ssh to your container by ssh-ing to that port on your local machine.
Connect with the user and password you specified in your `.env` file when you built the image.

```bash
# ssh to local machine is forwarded to the pod.
ssh -p 2222 <USR>@127.0.0.1
```

As the container will each time be on a different machine, you will have to reset the ssh key for the remote server.
You can do this with

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Moreover, so that you don't have to put your ssh keys on the remote server, you can forward your ssh keys with your ssh
agent (e.g. to connect to GitHub).
Follow the guide
[here](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding) with the following changes to your ssh config file.

```bash
Host runai
	HostName 127.0.0.1
	User <USR>
	Port 2222
	ForwardAgent yes
```
This would also allow you to simply `ssh runai` to your container.

**Limitations**

Note that an ssh connection to the container is not like executing a shell on the container. E.g.

- environment variables created when running the container are not available during ssh connections.
  You can work around this by explicitly adding them to the`.zshrc`
  with `echo "export VARIABLE=${VARIABLE}" >> ~/.zshrc` in the entrypoint script.
  This is already done for some variable.
  (Impact: one more line to add at build time.)

### PyCharm

We support the [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html) feature of
PyCharm
that runs a remote IDE in the container.
We prefer this method to using the container as
a [remote interpreter](https://www.jetbrains.com/help/pycharm/configuring-remote-interpreters-via-ssh.html), as with the
latter the code will have to be kept
in sync between the container and your local machine, creating a mismatch with the non-interactive way of running the
template.

There are two main ways to use PyCharm Remote development with an ssh server (here our container):

1. Using the JetBrains Gateway client to install the IDE in the server and connect to it.
2. The server has access to remote IDE binaries, starts the IDE on its own, and gives you a link to use with
   Gateway to directly connect to it.

The template supports both options.
We suggest using option 1 when you don't have access to the PyCharm remote IDE binaries as a first time.
Then settle with option 2 as it makes using Run:ai as your daily driver feel like just opening a local IDE.

For both options you will set your project directory on PyCharm to be the `${PROJECT_ROOT}=/opt/project` in the container.

**Preliminaries: saving the project IDE configuration**

The remote IDE stores its configuration (e.g. the interpreters you set up, memory )
in `~/.config/JetBrains/RemoteDev-PY/_opt_project`.
This is project-based.
Moreover, the project configuration is stored in `${PROJECT_ROOT}/.idea`.
To have both of these preserved between different dev containers you should create placeholder
directories in your PVC and the template will handle sym-linking them when the container starts.
A good place to create those directories as they are project-dependant is in your project root on your PVC,
which will look like this in the example we provide:
(You can use the `minimal.sh` or the `first_steps.sh` examples to access your PVC.)

```
/claire-rcp-scrach/home/moalla/template-project-name
├── dev             # The copy of your repository for development.
├── run             # The frozen copy of your repository for unattended jobs.
└── _pycharm-config
    ├── _config     # To contain the IDE .config for the project.
    └── _idea       # To contain the project .idea.
```

You should then specify the `PYCHARM_PROJECT_CONFIG_LOCATION` env variable with your submit command to maintain
your IDE and project configurations.

**Option 1**:

1. Submit your job as in the example `submit-examples/remote_development.sh` and in particular edit the environment
   variables
    - `PYCHARM_PROJECT_CONFIG_LOCATION` by setting to the `_pycharm-config` described above.
    - `PYCHARM_IDE_LOCATION` by deleting it as the IDE will be installed after the container is ran.
2. Enable ssh forwarding.
3. Then follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway).

You can then copy the directory containing the binaries `~/.cache/JetBrains/RemoteDev/dist/<some_pycharm_ide_version>` to your PVC
to use option 2. (E.g. to `/claire-rcp-scrach/home/moalla/remote-development/pycharm` in the example.)

**Option 2**:
You can find an example in `submit-examples/remote_development.sh`.

1. In your `runai submit` command, set the environment variables for
    - Opening an ssh server `SSH_SERVER=1`.
    - the path to PyCharm remote IDE binaries on your PVC `PYCHARM_IDE_LOCATION`.
    - preserving your config `PYCHARM_PROJECT_CONFIG_LOCATION`
    - Optionally, if your forward port is different from 2222 set `SSH_FORWARD_PORT`.

   Your IDE will start running with your container.
   It will print a link to the IDE in the container logs.

   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
    Gateway link: jetbrains-gateway://connect#idePath=%2Fclaire-rcp-scratch%2Fhome%2Fmoalla%2Fremote-development%2Fpycharm&projectPath=%2Fopt%2Fproject&host=127.0.0.1&port=2222&user=moalla&type=ssh&deploy=false&newUi=false
    ```
2. Enable ssh forwarding.
3. Use the Gateway link to connect to the remote IDE from a local JetBrains Gateway client as
   described [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#use_idea).

**Limitations**

- The terminal in PyCharm opens ssh connections to the container, so the limitations in the ssh section apply.
    - If needed, a workaround would be to just open a separate terminal on your local machine
      and directly exec a shell into the container.
- Support for programs with graphical interfaces (e.g. simulators) has not been tested yet.

### VSCode

We support the [Remote Development using SSH ](https://code.visualstudio.com/docs/remote/ssh) feature of
VS code that runs a remote IDE in the container.

**Preliminaries: saving the IDE configuration**

The remote IDE stores its configuration (e.g. the extensions you set up) in `~/.vscode-server`.
To have it preserved between different dev containers you should create placeholder
directory in your PVC and the template will handle sym-linking it when the container starts.
A good place to create this directory (as we treat it as project-dependant) is in your project root on your PVC,
which will look like this in the example we provide

```
/claire-rcp-scrach/home/moalla/template-project-name
├── dev             # The copy of your repository for development.
├── run             # The frozen copy of your repository for unattended jobs.
└── _vscode-server  # To contain the IDE .vscode-server for the project.
```

You should then specify the `VSCODE_PROJECT_CONFIG_LOCATION` env variable with your submit command to preserve
your IDE configuration.

**ssh configuration**

VS Code takes ssh configuration from files.
Edit your `~/.ssh/config` file to add the following if you didn't already.

```bash
Host runai
	HostName 127.0.0.1
	User <USR in .env>
	Port 2222
	ForwardAgent yes
```

**Connecting VS Code to the container**:

1. In your `runai submit` command, set the environment variables for
    - Opening an ssh server `SSH_SERVER=1`.
    - preserving your config `VSCODE_PROJECT_CONFIG_LOCATION`.
2. Enable ssh forwarding (and eventually `ssh-keygen -R '[127.0.0.1]:2222'`).
3. Have the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
   extension on your local VS Code.
4. Follow the steps [here](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host)

Set the root directory of your VS Code workspace to the `${PROJECT_ROOT}=/opt/project` on the container.

**Limitations**

- The terminal in VS Code opens ssh connections to the container, so the limitations in the ssh section apply.
    - If needed, a workaround would be to just open a separate terminal on your local machine
      and directly exec a shell into the container.
- Support for programs with graphical interfaces (e.g. simulators) has not been tested yet.

### JupyterLab

If you have `jupyterlab` in your `conda` dependencies, then the template can open a Jupyter Lab server for you when
the container starts.

To do so,

1. Set the `JUPYTER_SERVER=1` environment variable in your `runai submit` command.
   You can find an example in `submit-examples/remote_development.sh`.

   A Jupyter server will start running with your container. It will print a link to container logs.

   Get the logs with `runai logs <job-name>`.
   The link looks like:

   ```bash
   [C 2023-04-26 17:17:03.072 ServerApp]

    To access the server, open this file in a browser:
        ...
    Or copy and paste one of these URLs:
        http://localhost:8888/lab?token=6e302b1931cf81a87f786a70f616762547af8f4b3741c20c
        http://127.0.0.1:8888/lab?token=6e302b1931cf81a87f786a70f616762547af8f4b3741c20c
   ```

2. Forward the port `8888` on your local machine to the port `8888` on the container.
   ```bash
   kubeclt port-forward <job-name> 8888:8888
   ```

3. Open the link in your browser.

**Note:**

Development on Jupyter notebooks can be very useful, e.g. for quick iterations, plotting, etc, however,
it can very easily facilitate bad practices, such as debugging with print statements, prevalence of global variables,
relying on long-living kernel state, and hinder the reproducibility work.
We strongly recommend using an IDE with a proper debugger for development, which would fill the need for quick
iterations,
and only use Jupyter notebooks for plotting end results (where data is properly loaded from the output of a training
script).

**Limitations:**

- The author of the template does not use Jupyter Lab so limitations are not known yet.
  (Impact: unknown.)

### Examples

We provide examples of how to use the template in the `submit-examples` directory.
We use `submit` commands and not YAML files to specify job configurations because the Run:ai API for kubernetes resources
is still in alpha phase.

### Troubleshooting
