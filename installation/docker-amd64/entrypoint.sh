# Halt in case of errors. https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -eo pipefail
echo "Running entrypoint.sh"

# If the user sets EPFL_RUNAI=1, call the EPFL setup script.
if [ -n "${EPFL_RUNAI}" ]; then
  zsh "${EPFL_RUNAI_SETUP_DIR}"/setup.sh
fi

# W&B login.
# This does not need an internet connection.
if [ -n "${WANDB_API_KEY}" ]; then
  export WANDB_API_KEY="${WANDB_API_KEY}"
  wandb login "${WANDB_API_KEY}"
fi

# Exec so that the child process receives the OS signals.
# It will be PID 1.
exec "$@"
