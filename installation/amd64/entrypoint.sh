# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euxo pipefail

# if user sets EPFL_RUNAI=1, call the EPFL setup script.
if [ -n "${EPFL_RUNAI}" ]; then
  source "${EPFL_CONFIG_DIR}"/setup.sh
fi

# With login shell, wouldn't need the conda run
# Install the package in editable mode.
#conda run -n ${PROJECT_NAME} pip install -e .
pip install -e .
# Test that the template works. Feel free to remove this.
#conda run -n ${PROJECT_NAME} python -c "import <package-name>"
python -c "import <package-name>"

# Exec and --live-stream so that the child process receives the OS signals.
#exec conda run --live-streaming -n ${PROJECT_NAME} "$@"
exec "$@"
