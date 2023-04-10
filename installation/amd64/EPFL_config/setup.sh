# Workarounds to setup paths for EPFL.
# This is because runai does not allow to mount specific directories in PVCs.
# This script is sourced by the startup scripts.

# Sym-linking to the NFS.
# PROJECT_ROOT and *_DIR variables already defined in the Dockerfile.
# *_DIR_IN_NFS are environment variables injected with the runai submit command.
mkdir -p "${PROJECT_ROOT}"
ln -s "${CODE_DIR_IN_NFS}" "${CODE_DIR}"
ln -s "${DATA_DIR_IN_NFS}" "${DATA_DIR}"
ln -s "${LOGS_DIR_IN_NFS}" "${LOGS_DIR}"
