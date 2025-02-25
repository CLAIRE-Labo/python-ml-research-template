#!/bin/bash

#SBATCH -J template-remote-development
#SBATCH -t 12:00:00
#SBATCH --partition h100
#SBATCH --gpus 4
#SBATCH --cpus-per-task 60

# Only for Kuma temporarily

# If not done already in your bashrc (depends on the cluster so better write that logic there.)
# export SCRATCH=/scratch/moalla

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$HOME/projects/template-project-name/dev
export PROJECT_NAME=template-project-name
export PACKAGE_NAME=template_package_name
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
export WANDB_API_KEY_FILE_AT=$HOME/.wandb-api-key
export SSH_SERVER=1
export NO_SUDO_NEEDED=1
export JETBRAINS_SERVER_AT=$HOME/jetbrains-server
#export PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4
# or
# export VSCODE_SERVER_AT=$SCRATCH/vscode-server

srun \
  --container-image=$CONTAINER_IMAGES/claire+moalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --container-mounts=\
/etc/slurm,\
$PROJECT_ROOT_AT,\
$SCRATCH,\
$WANDB_API_KEY_FILE_AT,\
$JETBRAINS_SERVER_AT,\
$HOME/.gitconfig,\
$HOME/.ssh \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  -G 4 -c 60 \
  /opt/template-entrypoints/pre-entrypoint.sh \
  sleep infinity

# additional options
# --container-env to override environment variables defined in the container

# Draft.
# Here can connect to the container with
# Get the job id (and node id if multinode)
#
# Connect to the allocation
#   srun --overlap --pty --jobid=JOBID bash
# Inside the job find the container name
#   enroot list -f
# Exec to the container
#   enroot exec <container-pid> zsh

# additional options
# --container-env to override environment variables defined in the container
