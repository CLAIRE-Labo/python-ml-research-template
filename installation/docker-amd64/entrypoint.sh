# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -eo pipefail
echo "Running entrypoint.sh"

# If the user sets EPFL_RUNAI=1, call the EPFL setup script.
if [ -n "${EPFL_RUNAI}" ]; then
  zsh "${EPFL_RUNAI_SETUP_DIR}"/setup.sh
fi

# Install the package in editable mode.
echo "Installing the project."
pip install -e "${PROJECT_DIR}"
python -c "import ${PACKAGE_NAME}"

# Exec so that the child process receives the OS signals.
# It will be PID 1.
exec "$@"
