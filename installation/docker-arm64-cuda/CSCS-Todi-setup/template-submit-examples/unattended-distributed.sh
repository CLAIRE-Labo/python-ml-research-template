#!/bin/bash

#SBATCH -J template-untattended-distributed
#SBATCH -t 0:30:00
#SBATCH --nodes 3
#SBATCH --ntasks-per-node 2
#SBATCH --gpus-per-task 1

# There is a current limitation in pyxis with the entrypoint and it has to run manually.
# It has to run only once per node and the other tasks in the nodes have to wait for it to finish.
# So you can either limit your jobs to 1 task per node or use a sleep command to wait for the entrypoint to finish.


# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$SCRATCH/template-project-name/dev
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
export WANDB_API_KEY_FILE_AT=$HOME/.wandb-api-key

TO_RUN='bash -c "sleep 60 && exec python -m template_package_name.template_experiment some_arg=$SLURM_JOB_ID$SLURM_PROCID"'
# Sleep to wait for the entrypoint to perform some operations once per node

srun \
  enroot start \
  --rw \
  --conf "${PROJECT_ROOT_AT}/installation/docker-arm64-cuda/CSCS-Todi-setup/submit-scripts/enroot.conf.sh" \
  --mount $SCRATCH \
  --mount $WANDB_API_KEY_FILE_AT \
  -e PROJECT_ROOT_AT=$PROJECT_ROOT_AT \
  -e SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=$SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE \
  $CONTAINER_IMAGES/claire+smoalla+template-project-name+arm64-cuda-root-latest.sqsh \
  bash -c "cd \$PROJECT_ROOT_AT && exec ${TO_RUN}"