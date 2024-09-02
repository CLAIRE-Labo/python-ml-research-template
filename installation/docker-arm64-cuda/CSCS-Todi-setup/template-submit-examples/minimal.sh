#!/bin/bash

# Variables used by the entrypoint script
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$SCRATCH/template-project-name/dev
export SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE=1

# Enroot + Pyxis

# Limitation: pyxis doesn't send environment variables to the entrypoint so it has to be run manually
# This is fixed in v0.20.0

# Equivalent in enroot without pyxis

# Limitation: edf.toml is not used but its behaviour can be replicated with the enroot.conf.sh script
# Look at the file enroot.conf.sh for more details.

# Limitation: it's not clear how to change the workdir of the image as done above.
# This is replaced with a call to bash which does cd then execs what you need to run TO_RUN
# Note that the entrypoint will still run in the original workdir of the image
# You can fix this in the rc() function of enroot.conf.sh

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
  $CONTAINER_IMAGES/claire+smoalla+template-project-name+arm64-cuda-root-latest.sqsh \
  bash -c "cd \$PROJECT_ROOT_AT && exec $TO_RUN"