## Overview:
## Startup script for EPFL Run:ai: setup paths and run interactive setup for remote development.

## Remote development configuration
# Run interactive setup in the background if interactive job.
if [ -n "${EPFL_RUNAI_INTERACTIVE}" ]; then
  zsh "${EPFL_RUNAI_SETUP_DIR}"/interactive_startup.sh
fi

## Workarounds to setup paths for EPFL.
# Run:ai does not allow to mount specific directories from PVCs.
# Instead we will create symlinks to the specific directories in the PVCs.

## Variables
# *_DIR are environment variables already defined in the Dockerfile.
# *_DIR_IN_PVC are environment variables injected with the Run:ai submit command.

# Error if those variables are not set.
if [ -z "${PROJECT_DIR_IN_PVC}" ]; then
  echo "[TEMPLATE INFO] PROJECT_DIR_IN_PVC is not set. Exiting."
  exit 1
fi
if [ -z "${DATA_DIR_IN_PVC}" ]; then
  echo "[TEMPLATE INFO] DATA_DIR_IN_PVC is not set. Exiting."
  exit 1
fi
if [ -z "${OUTPUTS_DIR_IN_PVC}" ]; then
  echo "[TEMPLATE INFO] OUTPUTS_DIR_IN_PVC is not set. Exiting."
  exit 1
fi
if [ -z "${WANDB_DIR_IN_PVC}" ]; then
  echo "[TEMPLATE INFO] WANDB_DIR_IN_PVC is not set. Exiting."
  exit 1
fi

echo "[TEMPLATE INFO] Creating symlinks to directories in PVCs."
ln -s "${PROJECT_DIR_IN_PVC}" "${PROJECT_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${PROJECT_DIR} to ${PROJECT_DIR_IN_PVC}"
ln -s "${DATA_DIR_IN_PVC}" "${DATA_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${DATA_DIR} to ${DATA_DIR_IN_PVC}"
ln -s "${OUTPUTS_DIR_IN_PVC}" "${OUTPUTS_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${OUTPUTS_DIR} to ${OUTPUTS_DIR_IN_PVC}"
