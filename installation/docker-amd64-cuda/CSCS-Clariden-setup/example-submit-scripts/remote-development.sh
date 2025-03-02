#!/bin/bash

#SBATCH -J template-remote-development
#SBATCH -t 12:00:00

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$HOME/projects/template-project-name/dev
export PROJECT_NAME=template-project-name
export PACKAGE_NAME=template_package_name
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
export WANDB_API_KEY_FILE_AT=$HOME/.wandb-api-key
# You can remove the Hugging Face variables if you don't use it, also remove them from the container mounts.
export HF_TOKEN_AT=$HOME/.hf-token
export HF_HOME=$SCRATCH/huggingface

export SSH_SERVER=1
export NO_SUDO_NEEDED=1
# For the first time, mkdir -p $HOME/jetbrains-server, and comment out PYCHARM_IDE_AT
export JETBRAINS_SERVER_AT=$HOME/jetbrains-server
#export PYCHARM_IDE_AT=744eea3d4045b_pycharm-professional-2024.1.6-aarch64
# or
# export VSCODE_SERVER_AT=$HOME/vscode-server
# We use a different path than the default .vscode-server to separate the container installation from the local installation
# and replace JETBRAINS_SERVER_AT in the container-mounts with VSCODE_SERVER_AT

srun \
  --container-image=$CONTAINER_IMAGES/$(id -gn)+$(id -un)+template-project-name+amd64-cuda-root-latest.sqsh \
  --environment="${PROJECT_ROOT_AT}/installation/docker-amd64-cuda/CSCS-Clariden-setup/submit-scripts/edf.toml" \
  --container-mounts=\
$PROJECT_ROOT_AT,\
$SCRATCH,\
$WANDB_API_KEY_FILE_AT,\
$HOME/.gitconfig,\
$HF_TOKEN_AT,\
$JETBRAINS_SERVER_AT,\
$HOME/.ssh \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
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
