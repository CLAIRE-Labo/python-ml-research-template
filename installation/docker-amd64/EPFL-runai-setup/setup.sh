## Overview:
## Startup script for EPFL RunAI: setup paths and run interactive setup for remote development.

## SSH-only mode for first time use, or debugging.
if [ -n "${SSH_ONLY}" ]; then
  echo "SSH_ONLY is set. Only starting an ssh server without setup."
  # Install git as this option is primarily made to clone repos.
  echo "${PASSWD}" | DEBIAN_FRONTEND=noninteractive sudo -S apt-get update
  echo "${PASSWD}" | DEBIAN_FRONTEND=noninteractive sudo -S apt-get install -y git
  echo "${PASSWD}" | sudo -S /usr/sbin/sshd -D
  # The above runs in foreground, so the script will not continue.
  exit 1
fi

## Workarounds to setup paths for EPFL.
# RunAI does not allow to mount specific directories from PVCs.
# Instead we will create symlinks to the specific directories in the PVCs.
# TODO. Replace with direct subPath mounting with yaml submission when this is supported. (ticket INC0548857)

## Variables
# *_DIR are environment variables already defined in the Dockerfile.
# *_DIR_IN_PVC are environment variables injected with the RunAI submit command.

# Error if those variables are not set.
if [ -z "${PROJECT_DIR_IN_PVC}" ]; then
  echo "PROJECT_DIR_IN_PVC is not set. Exiting."
  exit 1
fi
if [ -z "${DATA_DIR_IN_PVC}" ]; then
  echo "DATA_DIR_IN_PVC is not set. Exiting."
  exit 1
fi
if [ -z "${OUTPUTS_DIR_IN_PVC}" ]; then
  echo "OUTPUTS_DIR_IN_PVC is not set. Exiting."
  exit 1
fi

ln -s "${PROJECT_DIR_IN_PVC}" "${PROJECT_DIR}"
ln -s "${DATA_DIR_IN_PVC}" "${DATA_DIR}"
ln -s "${OUTPUTS_DIR_IN_PVC}" "${OUTPUTS_DIR}"

## Remote development configuration
# Run interactive setup in the background if interactive job.
if [ -n "${EPFL_RUNAI_INTERACTIVE}" ]; then
  zsh "${EPFL_RUNAI_SETUP_DIR}"/interactive_startup.sh
fi
