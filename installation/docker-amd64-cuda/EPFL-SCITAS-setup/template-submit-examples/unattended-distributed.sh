#!/bin/bash

#SBATCH -J template-untattended-distributed
#SBATCH -t 0:30:00
#SBATCH --partition h100
#SBATCH --nodes 3
#SBATCH --ntasks-per-node 2
#SBATCH --gpus-per-task 1

# There is a current limitation in pyxis with the entrypoint and it has to run manually.
# It has to run only once per node and the other tasks in the nodes have to wait for it to finish.
# So you can either limit your jobs to 1 task per node or use a sleep command to wait for the entrypoint to finish.

# Only for Kuma temporarily

# If not done already in your bashrc (depends on the cluster so better write that logic there.)
# export SCRATCH=/scratch/moalla

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$SCRATCH/template-project-name/run
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
export WANDB_API_KEY_FILE_AT=$HOME/.wandb-api-key

srun \
  --container-image=$CONTAINER_IMAGES/claire+moalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --container-mounts=\
$SCRATCH:$SCRATCH,\
$WANDB_API_KEY_FILE_AT:$WANDB_API_KEY_FILE_AT \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  -G 1 \
  /opt/template-entrypoints/pre-entrypoint.sh \
  bash -c 'sleep 60; python -m template_package_name.template_experiment some_arg=$SLURM_JOB_ID$SLURM_PROCID'

# additional options
# --container-env to override environment variables defined in the container
