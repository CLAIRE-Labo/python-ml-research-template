####################
# Git config.
# Workaround when clusters do not allow to mount specific directories from PVCs.

if [ -n "${GIT_CONFIG_AT}" ]; then
  ln -s "${GIT_CONFIG_AT}" "${HOME}/.gitconfig"
  echo "[TEMPLATE INFO] Sym-linked Git config to ${GIT_CONFIG_AT}."
fi

####################
# Open ssh server.

if [ -n "${SSH_SERVER}" ]; then
  # Configuration for ssh server.
  # This could be done without sudo if needed.
  # check if user is not root
 echo "[TEMPLATE INFO] Configuring ssh server."
  if [ "${EUID}" -eq 0 ]; then
    mkdir /var/run/sshd
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
  else
    echo "${PASSWD}" | sudo -S mkdir /var/run/sshd
    echo "${PASSWD}" | sudo -S sed -i \
    's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
  fi

  # Export environment variables relevant for ssh connection.
  # SSH connections don't have the environment variables, so we need to set them.
  # Export all the env variables except the ones specific to the current shell.
  # Not sure if this is the best way to do it.
  env | grep -v -E '^(BASH|SHLVL|PWD|OLDPWD|_)' |\
   sed -E 's/=(.*)/="\1"/' | sed 's/^/export /' > "${HOME}"/docker-env-vars
  echo "source ${HOME}/docker-env-vars" >> "${HOME}"/.zshenv

  echo "[TEMPLATE INFO] Starting ssh server."
  # This runs in background, so the script will continue.
  if [ "${EUID}" -eq 0 ]; then
    /usr/sbin/sshd
  else
    echo "${PASSWD}" | sudo -S /usr/sbin/sshd
  fi
fi

####################
## PyCharm remote development server.
# You can set the env variable JETBRAINS_CONFIG_AT to persist your JetBrains configuration.
# You can set the env variable PYCHARM_IDE_AT to the location of the PyCharm binaries in your mounted storage.

if [ -n "${JETBRAINS_CONFIG_AT}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to PyCharm project config files."
  # Something that looks like ~/.config/JetBrains/
  # IDE project-config.
  mkdir -p "${HOME}/.config/"
  ln -s "${JETBRAINS_CONFIG_AT}" "${HOME}/.config/JetBrains"
  # Workaround to force zsh in the remote IDE terminal.
  # There's a bug and it keeps opening bash.
  echo "zsh" >> "${HOME}/.bashrc"
fi

if [ -n "${PYCHARM_IDE_AT}" ]; then
  echo "[TEMPLATE INFO] Starting PyCharm remote development server."

  REMOTE_DEV_NON_INTERACTIVE=1 \
    "${PYCHARM_IDE_AT}"/bin/remote-dev-server.sh run "${PROJECT_ROOT_AT}" \
    --ssh-link-host 127.0.0.1 \
    --ssh-link-user "${USER:-$(id -un)}" \
    --ssh-link-port "${SSH_FORWARD_PORT:-2222}" &
fi

####################
## VS Code remote development server.
# if the pycharm_ide_location variable is set:
if [ -n "${VSCODE_CONFIG_AT}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to VSCode server config files."
  ln -s "${VSCODE_CONFIG_AT}" "${HOME}/.vscode-server"
fi

#####################
# Jupyter Lab server.
# Jupyter must be installed with your conda environment.
if [ -n "${JUPYTER_SERVER}" ]; then
  echo "[TEMPLATE INFO] Starting Jupyter Lab server."
  # Workaround to open zsh.
  SHELL=zsh \
    jupyter-lab --no-browser --notebook-dir="${PROJECT_ROOT_AT}" &
fi
