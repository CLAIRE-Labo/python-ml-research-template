#!/bin/bash

#SBATCH -J template-unattended
#SBATCH -t 0:30:00

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$HOME/projects/template-project-name/run
export PROJECT_NAME=template-project-name
export PACKAGE_NAME=template_package_name
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1
# For wandb, huggingface, etc. look at the remote-development.sh

srun \
  --container-image=$CONTAINER_IMAGES/$(id -gn)+$(id -un)+template-project-name+amd64-cuda-root-latest.sqsh \
  --environment="${PROJECT_ROOT_AT}/installation/docker-amd64-cuda/CSCS-Clariden-setup/submit-scripts/edf.toml" \
  --container-mounts=$PROJECT_ROOT_AT,$SCRATCH \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  /opt/template-entrypoints/pre-entrypoint.sh \
  python -m template_package_name.template_experiment some_arg=some_value wandb.mode=offline

# additional options for pyxis
# --container-env to override environment variables defined in the container

exit 0
