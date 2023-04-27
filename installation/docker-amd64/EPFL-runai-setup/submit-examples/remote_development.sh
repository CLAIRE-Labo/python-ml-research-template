## PyCharm example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  --environment EPFL_RUNAI_INTERACTIVE=1 \
  --environment SSH_SERVER=1 \
  --environment PYCHARM_IDE_LOCATION=/mlodata1/moalla/remote-development/pycharm \
  --environment PYCHARM_PROJECT_CONFIG_LOCATION=/mlodata1/moalla/machrou3/pycharm-config \
  -- sleep infinity

## The new bits here are:
# --environment EPFL_RUNAI_INTERACTIVE=1
# which runs the EPFL RunAI interactive startup.
# --environment SSH_SERVER=1
# which starts an ssh server in the container. (Needed for PyCharm remote development)
# --environment PYCHARM_IDE_LOCATION=/mlodata1/moalla/remote-development/pycharm
# starts the PyCharm remote development server.
# --environment PYCHARM_PROJECT_CONFIG_LOCATION
# specifies the location of the PyCharm project configuration.

## Jupyter Lab example:
runai submit \
  --name example-remote-development \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  --environment EPFL_RUNAI_INTERACTIVE=1 \
  --environment JUPYTER_SERVER=1 \
  -- sleep infinity

## The new bits here are:
# --environment JUPYTER_SERVER=1

## Useful commands.
# runai describe job example-remote-development
# runai logs example-remote-development
# ssh-keygen -R '[127.0.0.1]:2222'
# kubectl port-forward example-remote-development-0-0  2222:22
# kubectl port-forward example-remote-development-0-0  8888:8888
