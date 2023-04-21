# Guide for using the template with the EPFL IC RunnAI cluster

## Overview

At this point, you should have an image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL IC RunAI cluster and use for:

1. Remote development (as at <lab-name> we use the RunAI platform as our daily drivers).
2. Running unattended jobs.

Using the image on the HaaS lab machines falls into the public instructions 
using the reproducible `local` Docker Compose servie and is covered by the
instructions in the `installation/docker-amd64/README.md` file.

## Prerequisites

**Docker image**:

Your should be able to deploy your docker image locally (on the machine you built it).
It will be hard to debug your image on RunAI if you can't even run it locally.

**RunAI**:

1. You should be familiar with the RunAI platform and be able to run jobs on it.
2. You should have access to [Harbor](https://ic-registry.epfl.ch),the EPFL IC Docker registry.
3. You should have one or more PVC(s) (Persistent Volume Claim) that you can use to store your data on the cluster.

Refer to this tutorial for an introduction to these tools (TODO: link to the EPIC guide.)

## First steps

### Push your image to the EPFL IC Docker registry

```bash
# Get your image name from the last line of the build output (ic-registry.epfl.ch/.../:...) 
docker push <image-name>
```

### Clone your repository in your PVCs

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

In addition, if you have multiple PVCs with different performance characteristics,
you may want to put your data and outputs on a different PVC than your code.
This is straightforward with this template and is covered in the examples provided.

If you already have those, e.g. because you have your PVC mounted on an ssh server that you use for development,
you can skip to the next section.
Otherwise, the template covers a deployment options that simply opens an ssh server on your container without setting up
the project, forwards your ssh keys, and allows you to clone your repository on the container.

1. Submit your job in the same fashion as `submit-examples/minimal.sh`.
2. 

### A quick test to understand how the template works

Adapt the `submit-examples/minimal.sh` with the name of your image, your PVC(s), and the correct paths to your project
in the PVC(s).

As in the example when you specify the `EPFL_RUNAI=1` environment variable with your script,
the entrypoint of the container will run an additional setup script that:

- Creates symlinks to the relevant directories in your PVCs on your project directory in the container.
  (Currently this is a workaround as RunAI does not support directly  mounting subdirectories of PVCs)
- Installs the project in editable mode. This is a lightweight installation that allows you to edit the code
  on your local machine and have the changes reflected in the container.
- Executes a provided command (e.g. `sleep infinity`), otherwise will run a shell and stop.

You need to make sure that this minimal submission works before proceeding.
You can check the logs of the container with `runai logs <job-name>` to see if everything is working as expected.

## Use cases

### Running unattended jobs

The first steps give all the required setup to run unattended jobs.
An example of an unattended job can be found in `submit-examples/unattended.sh`.
Note the emphasis on having a frozen copy of the repository for running unattended jobs.

### Remote development

This would be the typical use case for a researcher at <lab-name> using the RunAI cluster as their daily driver to do
development, testing, and debugging.
You would have a lightweight local IDE client running on you laptop, and a remote IDE instance running on the cluster.

When you specify an additional environment variable with your submitted job `EPFL_RUNAI_INTERACTIVE=1`,
the entrypoint will run an additional setup script that:

- starts an ssh server
- starts a remote development server

You can configure this to your needs with environment variables sent with the `runai submit` command:
An example of an interactive job submission can be found in `examples/remote_development.sh`

```bash
--environment EPFL_RUNAI_INTERACTIVE=1  # Is start the remote development setup script.
--environment SSH_FORWARD_PORT=<>       # Optional. Port on the local machine that forwards to the ssh server on the container.
                                        # Defaults to 2222.
--environment PYCHARM_IDE_LOCATION=<>   # Optional. Path to the PyCharm remote IDE binaries.
                                        # If specified, will start the remote IDE on the container.
--environment VSCODE_IDE_LOCATION # TODO.
--environment JUPYTER_SOMETHING # TODO.
```

#### SSH configuration

The ssh server is configured to run on port 22 of the container.
With RunAI, you can forward a local port on your machine to this port on the container.

That is, when your container is up, run

```bash
# Here 2222 on the local machine is forwarded to 22 on the pod.
# You can change the local port to whatever you want.
kubectl port-forward <pod-name> 2222:22
```

You can then ssh to your container by ssh-ing to that port on your local machine.
As the container will each time be on a different machine, you will have to reset the ssh key for the remote server.
You can do this with

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

Then ssh to the remote server with the user and password you specified in your `.env` file when you built the image.

```bash
# ssh to local machine is forwarded to the pod.
ssh -p 2222 <user>@127.0.0.1   
```

So that you don't have to put your ssh keys on the remote server, you can forward your ssh keys with your ssh
connection.
Follow the guide (
here)[https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding].
With the following changes to your ssh config file.

```bash
Match host 127.0.0.1 exec "test %p = 2222"
	ForwardAgent yes
```

#### PyCharm

There are two main ways to use
PyCharm [Remote Development](https://www.jetbrains.com/help/pycharm/remote-development-overview.html) with an ssh
server (here our container):

1. Using the JetBrains Gateway client to install the IDE in the server and connect to it.
2. The server has access to remote IDE binaries, starts the IDE on its own, and gives you a link to use with
   Gateway to directly connect to it.

The template supports both options.
We suggest using option 1 when you don't have access to the PyCharm remote IDE binaries as a first time.
Then settle with option 2 as it make using RunAI as your daily driver feel like just opening a local IDE.

Nevertheless, option 2 could have some bugs as we're not sure yet
how safe it is to have the directory containing the binaries of the IDE shared between machines.
Option 1 is bug free as it installs a fresh copy of the IDE on the container.

Make sure ssh forwarding from your local machine as described above is running.

_Option 1_:
Follow the instructions [here](https://www.jetbrains.com/help/pycharm/remote-development-a.html#gateway).

You can then copy the binaries in `~/.cache/JetBrains/RemoteDev/dist/<some_pycharm_ide_version>` to your PVC.
These can be shared among the users of the lab.

_Option 2_:

In your `runai submit` command,

- Set the environment variable for the path to PyCharm remote IDE binaries on your PVC `PYCHARM_IDE_LOCATION`.
- Optionally if your forward port is different from 2222 set `SSH_FORWARD_PORT`.

You can find an example in `examples/interactive_job.sh`.

Your IDE will start running with your container.
It will print a link to the IDE in the container logs.

Get the logs with `runai logs <job-name>`.
The link looks like:

```bash
Gateway link: jetbrains-gateway://connect#idePath=%2Fmlodata1%2Fmoalla%2Fremote_development%2Fpycharm&projectPath=%2Fopt%2Fproject&host=127.0.0.1&port=2222&user=&type=ssh&deploy=false
```

Use this link to connect to it from a local JetBrains Gateway client as described here

#### VSCode

#### JuptyerLab

Note: make a note that jupyter notebooks are harder to reproduce and do not fill well in a codebase.
Use them to experiment with plots maybe, but then copy the code to a proper script that outputs the figure
to a file.

### Troubleshooting