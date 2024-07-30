## See README for additional features like
# -e WANDB_API_KEY_FILE_AT=<>

## Go to the end of the file for useful commands and troubleshooting tips.

## PyCharm example:

# Option 1. No PyCharm on the remote server. Launch PyCharm from your local machine.
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e JETBRAINS_SERVER_AT=/claire-rcp-scratch/home/moalla/remote-development/jetbrains-server \
  -e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
  -- sleep infinity

# Option 2 (preferred). PyCharm launched from the remote server.
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4 \
  -e JETBRAINS_SERVER_AT=/claire-rcp-scratch/home/moalla/remote-development/jetbrains-server \
  -e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
  -- sleep infinity

## The new bits here are:
# -e PYCHARM_IDE_AT=<> starts the IDE from the container directly.

## VS Code example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e SSH_SERVER=1 \
  -e VSCODE_SERVER_AT=/claire-rcp-scratch/home/moalla/remote-development/vscode-server \
  -e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
  -- sleep infinity

## The new bits here are:
# -e VSCODE_SERVER_AT=<> will be mapped to ~/.vscode-server in the container

## Jupyter Lab example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig \
  -e JUPYTER_SERVER=1 \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
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
