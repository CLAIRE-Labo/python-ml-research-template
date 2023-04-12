# This is not part of the docker pipeline.
# This is an example of how to submit a job to runai.

# Read some of the variables from the .env file.
source ../.env

PROJECT_NAME="<project-name>"

runai submit \
  --name sandbox-home \
  --interactive \
  --image ${LAB_NAME}/ \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --pvc runai-mlo-moalla-mloraw1:/mloraw1 \
  --environment EPFL_RUNAI=1 \
  --environment CODE_DIR_IN_NFS=/mlodata1/${USER}/code/${PROJECT_NAME} \
  --environment DATA_DIR_IN_NFS=/mlodata1/${USER}/data/${PROJECT_NAME} \
  --environment LOGS_DIR_IN_NFS=/mlodata1/${USER}/logs/${PROJECT_NAME} \
  --environment PYCHARM_IDE_LOCATION=/mlodata1/${USER}/remote_development/pycharm \
  --environment WANDB_API_KEY=${WANDB_API_KEY} \
  -- sleep infinity <project-name >:${USR}
