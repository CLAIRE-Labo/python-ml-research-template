#!/bin/bash

# Enroot + Pyxis

srun \
  -J template-test \
  --overlap \
  --pty \
  --container-image=$CONTAINER_IMAGES/claire+smoalla+template-project-name+amd64-cuda-root-latest.sqsh \
  --environment="$(dirname "$0")/edf.toml" \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  pip list

exit 0
