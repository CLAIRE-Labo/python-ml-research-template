## Overview:
## Startup script for EPFL RunAI: setup paths and run interactive setup for remote development.

## SSH-only mode for first time use, or debugging.
if [ -n "${SSH_ONLY}" ]; then
  echo "SSH_ONLY is set. Only starting an ssh server without setup."
  echo "${PASSWD}" | sudo -S /usr/sbin/sshd -D
  # The above runs in foreground, so the script will not continue.
  exit 1
fi

## Workarounds to setup paths for EPFL.
# RunAI does not allow to mount specific directories from PVCs.
# Instead we will create symlinks to the specific directories in the PVCs.
# TODO. Replace with direct subPath mounting with yaml submission when this is supported. (ticket INC0548857)

## Variables
# PROJECT_ROOT and *_DIR are environment variables already defined in the Dockerfile.
# PROJECT_ROOT_IN_PVC and *_DIR_IN_OTHER_PVC are environment variables injected with the RunAI submit command.

# This is the ugly workaround to symlink the directories in the PVCs.
cd "${HOME}" || exit
# if project root exists delete it and replace it with a symlink to the project root in the PVC.
rm -r "${PROJECT_ROOT}"
# Error if PROJECT_ROOT_IN_PVC is not set.
if [ -z "${PROJECT_ROOT_IN_PVC}" ]; then
  echo "PROJECT_ROOT_IN_PVC is not set. Exiting."
  exit 1
fi
ln -s "${PROJECT_ROOT_IN_PVC}" "${PROJECT_ROOT}"
# If DATA_DIR_IN_OTHER_PVC is set symlink to it.
# If data directory exists (from current PROJECT_ROOT_IN_PVC) and only contains README.md delete it and replace it.
if [ -n "${DATA_DIR_IN_OTHER_PVC}" ]; then
  if [ -d "${DATA_DIR}" ] && [ "$(ls -A "${DATA_DIR}")" = "README.md" ]; then
    rm -r "${DATA_DIR}"
  fi
  ln -s "${DATA_DIR_IN_OTHER_PVC}" "${DATA_DIR}"
fi
# Same for outputs directory
if [ -n "${OUTPUTS_DIR_IN_OTHER_PVC}" ]; then
  if [ -d "${OUTPUTS_DIR}" ] && [ "$(ls -A "${OUTPUTS_DIR}")" = "README.md" ]; then
    rm -r "${OUTPUTS_DIR}"
  fi
  ln -s "${OUTPUTS_DIR_IN_OTHER_PVC}" "${OUTPUTS_DIR}"
fi

## Remote development configuration
# Run interactive setup in the background if interactive job.
if [ -n "${EPFL_RUNAI_INTERACTIVE}" ]; then
  zsh "${EPFL_CONFIG_DIR}"/interactive_startup.sh
fi
