####################
# Install a few user tools if not present.
# These are not a replacement for the tools installed in the base image.
# They should not be required for the project to run.
# Only for convenience during interactive development.
echo "${PASSWD}" | DEBIAN_FRONTEND=noninteractive sudo -S apt-get update
echo "${PASSWD}" | DEBIAN_FRONTEND=noninteractive sudo -S apt-get install -y \
  ca-certificates \
  curl \
  git \
  htop \
  vim \
  wget

####################
# Open ssh server.
if [ -n "${SSH_ONLY}" ]; then
  # SSH-only mode for first time use, or debugging.
  echo "${PASSWD}" | sudo -S /usr/sbin/sshd -D
  # The above runs in foreground, so the script will not continue.
else
  echo "${PASSWD}" | sudo -S /usr/sbin/sshd
  # This runs in background, so the script will continue.
fi

####################
## PyCharm remote development server.
# Set the env variable PYCHARM_IDE_LOCATION to the location of the PyCharm binaries in your NFS.
# Must have the binaries in your NFS.

# if the pycharm_ide_location variable is set:
echo "Starting PyCharm remote development server."
if [ -n "${PYCHARM_IDE_LOCATION}" ]; then

  if [ -n "${PYCHARM_PROJECT_CONFIG_LOCATION}" ]; then
    echo "Sym-linking to PyCharm project config files."
    # Project config.
    ln -s "${PYCHARM_PROJECT_CONFIG_LOCATION}/_idea" "${PROJECT_ROOT}/.idea"
    # IDE project-config.
    IDE_CONFIG_PARENT_DIR=~/.config/JetBrains/RemoteDev-PY/
    mkdir -p "${IDE_CONFIG_PARENT_DIR}"
    ln -s "${PYCHARM_PROJECT_CONFIG_LOCATION}/_config" "${CONFIG_PARENT_DIR}/_opt_project"
  fi

  REMOTE_DEV_NON_INTERACTIVE=1 \
    "${PYCHARM_IDE_LOCATION}"/bin/remote-dev-server.sh run "${PROJECT_ROOT}" \
    --ssh-link-host 127.0.0.1 \
    --ssh-link-user "${USER:-$(id -un)}" \
    --ssh-link-port "${SSH_FORWARD_PORT:-2222}" &
fi

####################
# VScode remote development server.
if [ -n "${VSCODE_IDE_LOCATION}" ]; then
  echo "VScode not yet supported."
fi
