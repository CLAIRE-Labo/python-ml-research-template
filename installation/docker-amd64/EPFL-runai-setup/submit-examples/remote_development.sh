## PyCharm example:

# Option 1. No PyCharm on the remote server. Launch PyCharm from your local machine.
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/claire/moalla/template-project-name:latest-dev \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e PYCHARM_PROJECT_CONFIG_LOCATION=/claire-rcp-scratch/home/moalla/template-project-name/_pycharm-config \
  -- sleep infinity

# Option 2 (preferred). PyCharm launched from the remote server.
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/claire/moalla/template-project-name:latest-dev \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e PYCHARM_PROJECT_CONFIG_LOCATION=/claire-rcp-scratch/home/moalla/template-project-name/_pycharm-config \
  -e PYCHARM_IDE_LOCATION=/claire-rcp-scratch/home/moalla/remote-development/pycharm \
  -- sleep infinity

## The new bits here are:
# -e EPFL_RUNAI_INTERACTIVE=1
# which runs the EPFL Run:ai interactive startup.
# -e SSH_SERVER=1
# which starts an ssh server in the container.
# -e PYCHARM_IDE_LOCATION=/claire-rcp-scratch/home/moalla/remote-development/pycharm
# starts the PyCharm remote development server.
# -e PYCHARM_PROJECT_CONFIG_LOCATION
# specifies the location of the PyCharm project configuration.

## VS Code example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/claire/moalla/template-project-name:latest-dev \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e DATA_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev/_data \
  -e OUTPUTS_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev/_outputs \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e VSCODE_PROJECT_CONFIG_LOCATION=/claire-rcp-scratch/home/moalla/template-project-name/_vscode-server \
  -- sleep infinity

## Jupyter Lab example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/claire/moalla/template-project-name:latest-dev \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e JUPYTER_SERVER=1 \
  -- sleep infinity

## Useful commands.
# runai describe job example-remote-development
# runai logs example-remote-development
# ssh-keygen -R '[127.0.0.1]:2222'
# kubectl port-forward example-remote-development-0-0  2222:22
# kubectl port-forward example-remote-development-0-0  8888:8888
