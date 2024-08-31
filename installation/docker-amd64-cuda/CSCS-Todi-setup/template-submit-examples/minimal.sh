#!/bin/bash

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$SCRATCH/template-project-name/dev
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1

# Enroot + Pyxis

# Limitation: pyxis doesn't send environment variables to the entrypoint so it has to be run manually
# This is fixed in v0.20.0

srun \
  -J template-minimal \
  --pty \
  --container-image=$CONTAINER_IMAGES/claire+smoalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --environment="$(dirname "$0")/edf.toml" \
  --container-mounts=$SCRATCH \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  /opt/template-entrypoints/pre-entrypoint.sh \
  bash

# additional options for pyxis
# --container-env to override environment variables defined in the container

exit 0

# Equivalent of the above with enroot without pyxis

# Limitation: edf.toml is not used but its behaviour can be replicated with the enroot.conf.sh script
# Look at the file enroot.conf.sh for more details.

# Limitation: it's not clear how to change the workdir of the image as done above.
# This is replaced with a call to bash which does cd then exec "$@"

TO_RUN='bash'

srun \
  -J template-minimal \
  --pty \
  enroot start \
  --rw \
  --conf "$(dirname "$0")/enroot.conf.sh" \
  --mount $SCRATCH \
  -e PROJECT_ROOT_AT=$PROJECT_ROOT_AT \
  -e SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1 \
  $CONTAINER_IMAGES/claire+smoalla+template-project-name+amd64-cuda-root-latest.sqsh \
  bash -c "cd \$PROJECT_ROOT_AT && exec $TO_RUN"
