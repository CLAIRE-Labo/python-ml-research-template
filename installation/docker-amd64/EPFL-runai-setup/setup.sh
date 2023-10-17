## Overview:
## Setup script for EPFL Run:ai. Setup paths and run interactive setup for remote development.

## Remote development configuration
# Run interactive setup in the background if interactive job.
if [ -n "${EPFL_RUNAI_INTERACTIVE}" ]; then
  zsh "${EPFL_RUNAI_SETUP_DIR}"/interactive_startup.sh
fi

## Workarounds to setup paths for EPFL.
# Run:ai does not allow to mount specific directories from PVCs.
# Instead we will create symlinks to the specific directories in the PVCs.

# This assumes a single datasets location.
# Edit this if you mount different datasets from different PVCs.
# E.g.
# Remove the lines about DATA_DIR_IN_PVC.
# Create the DATA_DIR with mkdir -p "${DATA_DIR}"
# and add lines like below at the bottom
#  ln -s "${SOME_SHARED_DATASET_IN_PVC}" "${DATA_DIR}/some-shared-dataset"
#  ln -s "${SOME_PRIVATE_DATASET_IN_PVC}" "${DATA_DIR}/some-private-dataset"


## Variables
# *_DIR are environment variables already defined in the Dockerfile.
# *_DIR_IN_PVC are environment variables passed with the Run:ai submit command.

if [ -z "${PROJECT_DIR_IN_PVC}" ]; then
    echo "[TEMPLATE INFO] PROJECT_DIR_IN_PVC is not set. Exiting."
    exit 1
else
  if [ -z "${DATA_DIR_IN_PVC}" ]; then
    DATA_DIR_IN_PVC="${PROJECT_DIR_IN_PVC}/_data"
  fi
  if [ -z "${OUTPUTS_DIR_IN_PVC}" ]; then
    OUTPUTS_DIR_IN_PVC="${PROJECT_DIR_IN_PVC}/_outputs"
  fi
  if [ -z "${WANDB_DIR_IN_PVC}" ]; then
    WANDB_DIR_IN_PVC="${PROJECT_DIR_IN_PVC}/_wandb"
  fi
fi

echo "[TEMPLATE INFO] Creating symlinks to directories in PVCs."
ln -s "${PROJECT_DIR_IN_PVC}" "${PROJECT_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${PROJECT_DIR} to ${PROJECT_DIR_IN_PVC}"
ln -s "${DATA_DIR_IN_PVC}" "${DATA_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${DATA_DIR} to ${DATA_DIR_IN_PVC}"
ln -s "${OUTPUTS_DIR_IN_PVC}" "${OUTPUTS_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${OUTPUTS_DIR} to ${OUTPUTS_DIR_IN_PVC}"
ln -s "${WANDB_DIR_IN_PVC}" "${WWANDB_DIR}"
echo "[TEMPLATE INFO] Sym-linked ${WWANDB_DIR} to ${WANDB_DIR_IN_PVC}"
