#!/bin/bash

# If not done already in your bashrc (depends on the cluster so better write that logic there.)
# export SCRATCH=/scratch/moalla

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$SCRATCH/template-project-name/dev
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1

srun \
  --container-image=$CONTAINER_IMAGES/claire+moalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --container-mounts=$SCRATCH:$SCRATCH \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  -G 1 --partition h100 -J template-minimal \
  --pty \
  /opt/template-entrypoints/pre-entrypoint.sh \
  bash

# additional options
# --container-env to override environment variables defined in the container
