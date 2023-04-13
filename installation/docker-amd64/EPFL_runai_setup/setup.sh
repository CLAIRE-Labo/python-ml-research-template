# Workarounds to setup paths for EPFL.
# This is because RunAI does not allow to mount specific directories in PVCs.
# This is currently not so beautiful.

# Sym-linking to the NFS.
# PROJECT_ROOT and *_DIR variables already defined in the Dockerfile.
# *_DIR_IN_NFS are environment variables injected with the runai submit command.

# Delete the code directory if it exists and is empty (to avoid deleting mounted directories by accident).
cd "${HOME}" || exit 1
if [ -d "${CODE_DIR}" ] && [ -z "$(ls -A "${CODE_DIR}")" ]; then
    rm -rf "${CODE_DIR}"
fi
ln -s "${CODE_DIR_IN_NFS}" "${CODE_DIR}"
ln -s "${DATA_DIR_IN_NFS}" "${DATA_DIR}"
ln -s "${LOGS_DIR_IN_NFS}" "${LOGS_DIR}"
cd "${CODE_DIR}" || exit 1

# Run interactive setup in the background if interactive job.
if [ -z "${EPFL_RUNAI_INTERACTIVE}" ]; then
    /bin/zsh "${EPFL_CONFIG_DIR}"/interactive_startup.sh &
fi
