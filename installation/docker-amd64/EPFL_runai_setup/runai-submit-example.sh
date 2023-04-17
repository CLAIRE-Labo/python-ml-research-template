# This is not part of the docker pipeline.
# This is an example of how to submit a job to runai.


USR=moalla
PROJECT_NAME=my-project
LAB_NAME=moalla
IMAGE_TAG=latest
CODE_DIR_IN_PVC=/mlodata1/${USR}/${PROJECT_NAME}/code
DATA_DIR_IN_PVC=/mlodata1/${USR}/${PROJECT_NAME}/data
OUTPUTS_DIR_IN_PVC=/mlodata1/${USR}/${PROJECT_NAME}/outputs
PYCHARM_IDE_LOCATION=/mlodata1/"${USR}"/remote_development/pycharm
IMAGE_NAME=ic-registry.epfl.ch/${LAB_NAME}/${PROJECT_NAME}/${USR}:${IMAGE_TAG}

runai submit \
  --name test-template \
  --interactive \
  --image "${IMAGE_NAME}" \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --pvc runai-mlo-moalla-mloraw1:/mloraw1 \
  --environment EPFL_RUNAI=1 \
  --environment CODE_DIR_IN_PVC="${CODE_DIR_IN_PVC}" \
  --environment DATA_DIR_IN_PVC="${DATA_DIR_IN_PVC}" \
  --environment OUTPUTS_DIR_IN_PVC="${OUTPUTS_DIR_IN_PVC}" \
  --environment PYCHARM_IDE_LOCATION="${PYCHARM_IDE_LOCATION}" \
  --environment WANDB_API_KEY="${WANDB_API_KEY}" \
  -- sleep infinity
