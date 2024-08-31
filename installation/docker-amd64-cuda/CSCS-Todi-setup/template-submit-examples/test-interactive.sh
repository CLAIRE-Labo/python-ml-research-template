#!/bin/bash

# Enroot + Pyxis

srun \
  -J template-test \
  --pty \
  --container-image=$CONTAINER_IMAGES/claire+smoalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  bash

exit 0

# Equivalent of the above in enroot without pyxis

# Limitation: it's not clear how to remove the entrypoint of the image as done above with just a flag.
# We do it with a --conf file.
# This just for the test anyway. In general the entrypoint should be kept.

srun \
  -J template-test \
  --pty \
  enroot start \
  --rw \
  --conf "$(dirname "$0")/enroot-no-entrypoint.conf.sh" \
  $CONTAINER_IMAGES/claire+smoalla+template-project-name+amd64-cuda-root-latest.sqsh \
  echo 1
