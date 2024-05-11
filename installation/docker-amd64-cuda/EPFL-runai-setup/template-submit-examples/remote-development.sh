## See README for additional features like
# -e GIT_CONFIG_AT=<>
# -e WANDB_API_KEY_FILE_AT=<>

## PyCharm example:

# Option 1. No PyCharm on the remote server. Launch PyCharm from your local machine.
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-dev-latest-moalla \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e PYCHARM_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/pycharm-config \
  -- sleep infinity

# Option 2 (preferred). PyCharm launched from the remote server.
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-dev-latest-moalla \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e PYCHARM_IDE_AT=/claire-rcp-scratch/home/moalla/remote-development/pycharm \
  -e PYCHARM_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/pycharm-config \
  -- sleep infinity

## The new bits here are:
# -e PYCHARM_IDE_AT=<> starts the IDE from the container directly.

## VS Code example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-dev-latest-moalla \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e VSCODE_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/vscode-server \
  -- sleep infinity

## The new bits here are:
# -e VSCODE_CONFIG_AT=<> will be mapped to ~/.vscode-server in the container

## Jupyter Lab example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-dev-latest-moalla \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e JUPYTER_SERVER=1 \
  -- sleep infinity

## The new bits here are:
# -e JUPYTER_SERVER=1 will start a Jupyter Lab server in the container.

## Useful commands.
# runai describe job example-remote-development
# runai logs example-remote-development
# kubectl port-forward example-remote-development-0-0  2222:22
# ssh runai
# kubectl port-forward example-remote-development-0-0  8888:8888
# runai logs example-remote-development
# Get the link and paste it in your browser, replacing hostname with localhost.

## Troubleshooting.
# When you add a new line for an environment variable or a GPU, etc., remember to add a \ at the end of the line.
# ... \
# -e SOME_ENV_VAR=1 \
# -g 1 \
#...
# -- sleep infinity
