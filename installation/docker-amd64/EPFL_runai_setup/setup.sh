## Overview:
## Startup script for EPFL RunAI: setup paths and run interactive setup for remote development.


## Workarounds to setup paths for EPFL.
# RunAI does not allow to mount specific directories from PVCs.
# Instead we will create symlinks to the specific directories in the PVCs.
# TODO. Find a better solution with yaml submission when subpath mounting is supported.

## Variables
# *_DIR are environment variables already defined in the Dockerfile.
# *_DIR_IN_PVC are environment variables injected with the RunAI submit command.

ln -s "${CODE_DIR_IN_PVC}" "${CODE_DIR}"
ln -s "${DATA_DIR_IN_PVC}" "${DATA_DIR}"
ln -s "${OUTPUTS_DIR_IN_PVC}" "${OUTPUTS_DIR}"

## Remote development configuration
# Run interactive setup in the background if interactive job.
if [ -n "${EPFL_RUNAI_INTERACTIVE}" ]; then
    zsh "${EPFL_CONFIG_DIR}"/interactive_startup.sh
fi
