# Guide for using the template with the IC runai cluster

## Prerequisites

### Submitting jobs
### Running jobs interactively

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

So that you don't have to put your ssh keys on the remote server, you can forward your ssh keys with your ssh connection.
Follow the guide (here)[https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-agent-forwarding].
With the following changes to your ssh config file.
```bash
Match host 127.0.0.1 exec "test %p = 2222"
	ForwardAgent yes
```
