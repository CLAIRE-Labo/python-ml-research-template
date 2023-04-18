# Guide for using the template with the EPFL IC RunnAI cluster

## Overview

At this point, you should have an image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL IC RunAI cluster and use for:

1. Running unattended jobs.
2. Remote development (as at <lab-name> we use the RunAI platform as our daily drivers).

Using the image on the HaaS lab machines falls into the general reproducible use case and is covered by the
instructions in the `installation/docker-amd64/README.md` file.

## Prerequisites

### Common

**RunAI**:

1. You should be familiar with the RunAI platform and be able to run jobs on it.
   Refer to this tutorial for a quick introduction.
2. You should have one or more PVC(s) (Persistent Volume Claim) that you can use to store your data on the cluster.
   Refer to this tutorial for a quick introduction.

**Workflow**:

We strongly suggest having two instances of your project repository on your PVCs.

1. One for development, which may have uncommitted changes, be in a broken state, etc.
2. One for running unattended jobs, which is always referring to a commit at a working state of the code.

   Note: you may have several of these frozen repositories, or you may add a checkout command in your entrypoint.

   TODO: implement an env variable that allows checking a commit in the entrypoint.

In addition, if you have multiple PVCs with different performance characteristics,
you may want to put your data and outputs on a different PVC than your code.
This is straightforward with this template and is covered in the instructions below.

### Running unattended jobs

### Remote development

- JetBrain Gateway on your local machine.
- PyCharm Remote Development server on your

https://www.jetbrains.com/help/pycharm/remote-development-a.html#use_idea

Install JetBrains Gateway on your local computer.
Submit the

~/binaries/pycharm/bin/remote-dev-server.sh run ~/proj/ --ssh-link-host 127.0.0.1 --ssh-link-port 2222

PyCharm saved settings will be

## Use cases

### First steps

Edit the example script

When you specify the `EPFL_RUNAI=1` environment variable with your script, the entrypoint of the conainter
will run an additional setup script that:

- Creates symlinks to the relevant directories in your PVCs on your project directory in the container.
- Installs the project in editable mode. This is a lightweight installation that allows you to edit the code
  on your local machine and have the changes reflected in the container.
- Runs your provided command (e.g. `python -m package.train lr=0.1`) otherwise it will run a shell.

### Running unattended jobs

The only thing you have to do after the first steps is to submit a job to the RunAI cluster with the command to run.
An example of a job submission can be found in `examples/job.sh`

### Remote development

This would be the typical use case for a researcher at <lab-name> using the RunAI cluster as their daily driver.
You would have a lightweight local IDE client running on you laptop, and a remote IDE instance running on the cluster.

When you specify an additional environment variable with your submitted job `EPFL_RUNAI_INTERACTIVE=1`,
the entrypoint will run an additional setup script that:

- starts an ssh server
- starts a remote development server

You can configure this to your needs with environment variables sent with the job submission `runai submit` command:

```bash
Foo=bar # does blah.
```

An example of an interactive job submission can be found in `examples/interactive_job.sh`

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

Set the environment variable for the path to PyCharm remote IDE binaries on your PVC
`PYCHARM_IDE_LOCATION`.
Optionally if your forward port is different from 2222 set `SSH_FORWARD_PORT`.

Your IDE will start running with your container.
It will print a link to the IDE in the container logs.

Use this link to connect to it from a local JetBrains Gateway client.

#### VSCode

#### JuptyerLab

Note: make a note that jupyter notebooks are harder to reproduce and do not fill well in a codebase.
Use them to experiment with plots maybe, but then copy the code to a proper script that outputs the figure
to a file.

### Troubleshooting