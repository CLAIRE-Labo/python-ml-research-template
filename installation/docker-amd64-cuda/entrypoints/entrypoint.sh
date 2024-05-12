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
  PROJECT_ROOT_AT="$(pwd)"
  SKIP_INSTALL_PROJECT=1
  export PROJECT_ROOT_AT
  export SKIP_INSTALL_PROJECT
else
  echo "[TEMPLATE INFO] PROJECT_ROOT_AT is set to ${PROJECT_ROOT_AT}."
fi
# Run the rest from the project root.
# This is set in the entrypoint and not in the Dockerfile as a Workdir
# to accommodate deployment options which can't mount subdirectories to specific locations.
# (so we cannot assume a predefined location for the project).
echo "[TEMPLATE INFO] The next commands will be run from ${PROJECT_ROOT_AT}."
echo "[TEMPLATE INFO] Interactive zsh shells will also be started in ${PROJECT_ROOT_AT}."
cd "${PROJECT_ROOT_AT}"

# Install the package in editable mode.
# Also ensures the code is mounted correctly.
if [ -n "${SKIP_INSTALL_PROJECT}" ]; then
  # For debugging or other purposes.
  # Best practice is to install the project.
  echo "[TEMPLATE INFO] Skipping the installation of the project."
else
  echo "[TEMPLATE INFO] Installing the project with pip."
  echo "[TEMPLATE INFO] Expecting ${PROJECT_ROOT_AT} to be a Python project."
  echo "[TEMPLATE INFO] To skip this installation use the env variable SKIP_INSTALL_PROJECT=1."
  # The path is relative on purpose.
  pip install --user -e .
  # Test that the package can be imported.
  echo "[TEMPLATE INFO] Testing that the package can be imported."
  python -c "import ${PACKAGE_NAME}"
  echo "[TEMPLATE INFO] Package imported successfully."
fi

# Login options, e.g., wandb.
# Doesn't do anything if no option provided.
zsh "${ENTRYPOINTS_ROOT}"/logins-setup.sh

# Remote development options (e.g., PyCharm or VS Code configuration, Jupyter etc).
# Doesn't do anything if no option provided.
zsh "${ENTRYPOINTS_ROOT}"/remote-development-setup.sh

# Exec so that the child process receives the OS signals.
# E.g., signals that the container will be preempted.
# It will be PID 1.
echo "[TEMPLATE INFO] Executing the command" "$@"
exec "$@"
