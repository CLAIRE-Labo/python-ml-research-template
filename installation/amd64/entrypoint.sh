# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -eo pipefail
echo "Running entrypoint.sh"

# if user sets EPFL_RUNAI=1, call the EPFL setup script.
if [ -n "${EPFL_RUNAI}" ]; then
  source "${EPFL_CONFIG_DIR}"/setup.sh
fi

# With login shell, wouldn't need the conda run
# Install the package in editable mode.
echo "Installing the project."
pip install -e .

# Test that the template works. Feel free to remove this.
python -c "import <package_name>"

# Exec and --live-stream so that the child process receives the OS signals.
#exec conda run --live-streaming -n ${PROJECT_NAME} "$@"
exec "$@"
