echo "[TEMPLATE INFO] Entering EPFL Run:ai interactive startup."

####################
# Git config.

if [ -n "${GIT_CONFIG_IN_PVC}" ]; then
  ln -s "${GIT_CONFIG_IN_PVC}" "${HOME}/.gitconfig"
  echo "[TEMPLATE INFO] Sym-linked Git config to ${GIT_CONFIG_IN_PVC}."
fi

####################
# Open ssh server.

if [ -n "${SSH_SERVER}" ]; then
  # Configuration for ssh server.
  echo "[TEMPLATE INFO] Configuring ssh server."
  echo "${PASSWD}" | sudo -S mkdir /var/run/sshd
  echo "${PASSWD}" | sudo -S sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

  # Let login shells be in the project root by default.
  echo "cd ${PROJECT_ROOT}" >>"${ZDOTDIR}"/.zshrc

  # Export environment variables relevant for ssh connection.
  # SSH connections don't have the environment variables, so we need to set them.
  {
    echo "export PROJECT_NAME=${PROJECT_NAME}"
    echo "export PACKAGE_NAME=${PACKAGE_NAME}"
    echo "export PROJECT_DIR=${PROJECT_DIR}"
    echo "export DATA_DIR=${DATA_DIR}"
    echo "export OUTPUTS_DIR=${OUTPUTS_DIR}"
    echo "export LANG=${LANG}"
    echo "export LC_ALL=${LC_ALL}"
    echo "export PYTHONENCODING=${PYTHONENCODING}"
    echo "export PASSWD=${PASSWD}"
    echo "export LD_PRELOAD=${LD_PRELOAD}"
  } >>"${ZDOTDIR}"/.zshrc

  if [ -n "${SSH_ONLY}" ]; then
    # SSH-only mode for first time use, or debugging.
    echo "[TEMPLATE INFO] SSH_ONLY mode enabled."
    echo "${PASSWD}" | sudo -S /usr/sbin/sshd -D
    # The above runs in foreground, so the script will not continue.
  else
    echo "[TEMPLATE INFO] Starting ssh server."
    echo "${PASSWD}" | sudo -S /usr/sbin/sshd
    # This runs in background, so the script will continue.
  fi
fi

####################
## PyCharm remote development server.
# You can set the env variable PYCHARM_PROJECT_CONFIG_LOCATION to the location of the PyCharm project config files in your NFS.
# You can the env variable PYCHARM_IDE_LOCATION to the location of the PyCharm binaries in your NFS.

if [ -n "${PYCHARM_PROJECT_CONFIG_LOCATION}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to PyCharm project config files."

  # Project config.
  ln -s "${PYCHARM_PROJECT_CONFIG_LOCATION}/_idea" "${PROJECT_ROOT}/.idea"

  # IDE project-config.
  IDE_CONFIG_PARENT_DIR=~/.config/JetBrains/RemoteDev-PY/
  mkdir -p "${IDE_CONFIG_PARENT_DIR}"
  ln -s "${PYCHARM_PROJECT_CONFIG_LOCATION}/_config" "${IDE_CONFIG_PARENT_DIR}/_opt_project"

  # Workaround to force zsh in the remote IDE terminal.
  # There's a bug and it keeps opening bash.
  echo "zsh" >>.bashrc
fi

if [ -n "${PYCHARM_IDE_LOCATION}" ]; then
  echo "[TEMPLATE INFO] Starting PyCharm remote development server."
  REMOTE_DEV_NON_INTERACTIVE=1 \
    "${PYCHARM_IDE_LOCATION}"/bin/remote-dev-server.sh run "${PROJECT_ROOT}" \
    --ssh-link-host 127.0.0.1 \
    --ssh-link-user "${USER:-$(id -un)}" \
    --ssh-link-port "${SSH_FORWARD_PORT:-2222}" &
fi

####################
## VS Code remote development server.
# if the pycharm_ide_location variable is set:
if [ -n "${VSCODE_PROJECT_CONFIG_LOCATION}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to VSCode server config files."
  ln -s "${VSCODE_PROJECT_CONFIG_LOCATION}" "${HOME}/.vscode-server"
fi

#####################
# Jupyter Lab server.
# Jupyter must be installed with your conda environment.
if [ -n "${JUPYTER_SERVER}" ]; then
  echo "[TEMPLATE INFO] Starting Jupyter Lab server."
  # Workaround to open zsh.
  SHELL=zsh \
    jupyter-lab --no-browser --notebook-dir="${PROJECT_ROOT}" &
fi
