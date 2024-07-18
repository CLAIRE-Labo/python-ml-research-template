#!/bin/bash
# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -eo pipefail
echo "[TEMPLATE INFO] Running entrypoint.sh"

# Check that the PROJECT_ROOT_AT is set.
if [ -z "${PROJECT_ROOT_AT}" ]; then
  echo "[TEMPLATE WARNING] PROJECT_ROOT_AT is not set."
  echo "[TEMPLATE WARNING] It is expected to point to the location of your mounted project if you plan to run you code."
  echo "[TEMPLATE WARNING] Ignore if you only need the development environment."
  echo "[TEMPLATE WARNING] PROJECT_ROOT_AT has been defaulted to $(pwd)"
  echo "[TEMPLATE WARNING] The project installation will be skipped."
  export PROJECT_ROOT_AT="$(pwd)"
  export SKIP_INSTALL_PROJECT=1
else
  echo "[TEMPLATE INFO] PROJECT_ROOT_AT is set to ${PROJECT_ROOT_AT}."
fi
echo "[TEMPLATE INFO] Expecting workdir to be ${PROJECT_ROOT_AT}."

if [ "$(pwd)" != "${PROJECT_ROOT_AT}" ]; then
  echo "[TEMPLATE WARNING] The current/working directory $(pwd) is different from PROJECT_ROOT_AT."
  echo "[TEMPLATE WARNING] The template expects them to be the same."
fi

# Install the package in editable mode.
# Also ensures the code is mounted correctly.
# Because setting the Python path the the project may not be enough.
# https://pip.pypa.io/en/stable/topics/local-project-installs/#editable-installs
if [ -n "${SKIP_INSTALL_PROJECT}" ] || [ -n "${SLURM_ENTRYPOINT_ONCE_PER_TASK}" ] && [ "${SLURM_LOCALID}" -eq 0 ]; then
  # For debugging or other purposes.
  # For Slurm, assuming container entrypoing is run only once per node, only run once per node
  # Also install only once per node.
  # Best practice is to install the project.
  echo "[TEMPLATE INFO] Skipping the installation of the project."
else
  echo "[TEMPLATE INFO] Installing the project with pip."
  echo "[TEMPLATE INFO] Expecting ${PROJECT_ROOT_AT} to be a Python project."
  echo "[TEMPLATE INFO] To skip this installation use the env variable SKIP_INSTALL_PROJECT=1."
  # The path is relative on purpose.
  pip install --user -e "${PROJECT_ROOT_AT}"
  # Test that the package can be imported.
  echo "[TEMPLATE INFO] Testing that the package can be imported."
  python -c "import ${PACKAGE_NAME}"
  echo "[TEMPLATE INFO] Package imported successfully."
fi

# Login options, e.g., wandb.
# Doesn't do anything if no option provided.
source "${ENTRYPOINTS_ROOT}"/logins-setup.sh

# Remote development options (e.g., PyCharm or VS Code configuration, Jupyter etc).
# Doesn't do anything if no option provided.
source "${ENTRYPOINTS_ROOT}"/remote-development-setup.sh

# Exec so that the child process receives the OS signals.
# E.g., signals that the container will be preempted.
# It will be PID 1.
echo "[TEMPLATE INFO] Executing the command" "$@"
exec "$@"
