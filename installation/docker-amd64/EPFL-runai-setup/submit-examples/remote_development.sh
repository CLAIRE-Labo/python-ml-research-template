## PyCharm example:

# Option 1. No PyCharm on the remote server. Launch PyCharm from your local machine.
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:dev \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  -e DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  -e OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e PYCHARM_PROJECT_CONFIG_LOCATION=/mloraw1/moalla/implicit-pg/_pycharm-config \
  -- sleep infinity

# Option 2 (preferred). PyCharm launched from the remote server.
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:dev \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  -e DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  -e OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e PYCHARM_PROJECT_CONFIG_LOCATION=/mlodata1/moalla/machrou3/_pycharm-config \
  -e PYCHARM_IDE_LOCATION=/mlodata1/moalla/remote-development/pycharm \
  -- sleep infinity

## The new bits here are:
# -e EPFL_RUNAI_INTERACTIVE=1
# which runs the EPFL RunAI interactive startup.
# -e SSH_SERVER=1
# which starts an ssh server in the container.
# -e PYCHARM_IDE_LOCATION=/mlodata1/moalla/remote-development/pycharm
# starts the PyCharm remote development server.
# -e PYCHARM_PROJECT_CONFIG_LOCATION
# specifies the location of the PyCharm project configuration.

## VS Code example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  -e DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  -e OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e SSH_SERVER=1 \
  -e VSCODE_PROJECT_CONFIG_LOCATION=/mlodata1/moalla/machrou3/_vscode-server \
  -- sleep infinity

## Jupyter Lab example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  -e DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  -e OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -e EPFL_RUNAI_INTERACTIVE=1 \
  -e JUPYTER_SERVER=1 \
  -- sleep infinity

## Useful commands.
# runai describe job example-remote-development
# runai logs example-remote-development
# ssh-keygen -R '[127.0.0.1]:2222'
# kubectl port-forward example-remote-development-0-0  2222:22
