# Guide for using the template with the EPFL IC RunnAI cluster

## Overview

At this point, you should have an image that can be deployed on multiple platforms.
This guide will show you how to deploy your image on the EPFL IC RunAI cluster as use for:

1. Running unattended jobs.
2. Remote development (as at <lab-name> we use the RunAI platform as our daily drivers).

Using the image on the HaaS lab machines falls into the general reproducible use case and is covered by the
instructions in the `installation/amd64/README.md` file.

## Prerequisites

### Common

You should be familiar wit

### Running unattended jobs.

### Remote development

- JetBrain Gateway on your local machine.
- PyCharm Remote Development server on your

https://www.jetbrains.com/help/pycharm/remote-development-a.html#use_idea

Install JetBrains Gateway on your local computer.
Submit the

~/binaries/pycharm/bin/remote-dev-server.sh run ~/proj/ --ssh-link-host 127.0.0.1 --ssh-link-port 2222

PyCharm saved settings will be

## SSH configuration

Remember to reset the ssh key for the remote server as it changes every time you submit a job.

```bash
ssh-keygen -R '[127.0.0.1]:2222'
```

## SSH forwarding.

So that you don't have to put your ssh keys on the remote server, you can forward your ssh keys with your ssh
connection.
Follow the guide (
here)[https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding].
With the following changes to your ssh config file.

```bash
Match host 127.0.0.1 exec "test %p = 2222"
	ForwardAgent yes
```
