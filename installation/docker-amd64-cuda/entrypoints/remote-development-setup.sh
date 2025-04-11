####################
# Git config.
# Workaround using symlinks when clusters do not allow to mount specific directories or files.

if [ -n "${GIT_CONFIG_AT}" ]; then
  mkdir -p $(dirname "${GIT_CONFIG_AT}")
  touch "${GIT_CONFIG_AT}"
  ln -s "${GIT_CONFIG_AT}" "${HOME}/.gitconfig"
  echo "[TEMPLATE INFO] Sym-linked Git config to ${GIT_CONFIG_AT}."
fi

####################
# Open ssh server.

if [ -n "${SSH_SERVER}" ] || [ -n "${SOURCE_ENV_FOR_SSH}" ];then
  # Export environment variables lost through ssh connection.
  # (Assumes a single user).
  # SSH connections don't have the environment variables, so we need to set them.
  # Export all the env variables except the ones specific to the current shell.
  # Not sure if this is the best way to do it.
  env | grep -v -E '^(BASH|SHLVL|PWD|OLDPWD|SHELL|LOGNAME|_| |\}|\{)' |\
   sed -E 's/=(.*)/="\1"/' | sed 's/^/export /' > "${HOME}"/.container-env-vars
  # Export to login shells.
  echo "source ${HOME}/.container-env-vars" >> "${HOME}/.bash_profile"
  echo "source ${HOME}/.container-env-vars" >> "${HOME}/.zprofile"
  echo "[TEMPLATE INFO] Environment variables have been written to ${HOME}/.docker-env-vars."
  echo "[TEMPLATE_INFO] And will be sourced in login shells to preserve environment variables in ssh connections."
  echo "[TEMPLATE INFO] If you change one at runtime and want it to be preserved in subsequence shell invocations, you need to write it to ${HOME}/.docker-env-vars as well."
fi


if [ -n "${SSH_SERVER}" ]; then
  # Configuration for ssh server.
  # This could be done without sudo if needed.
  # check if user is not root
 echo "[TEMPLATE INFO] Configuring ssh server on port ${SSH_CONTAINER_PORT:-2223}."
  if [ "${EUID}" -eq 0 ] || [ -n "${NO_SUDO_NEEDED}" ]; then
    mkdir /var/run/sshd
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
    # Change the default port to ${SSH_CONTAINER_PORT}.
    sed -i "s/#Port 22/Port ${SSH_CONTAINER_PORT:-2223}/" /etc/ssh/sshd_config
  else
    echo "${PASSWD}" | sudo -S mkdir /var/run/sshd
    echo "${PASSWD}" | sudo -S sed -i \
    's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
    # Change the default port to ${SSH_CONTAINER_PORT}.
    echo "${PASSWD}" | sudo -S sed -i "s/#Port 22/Port ${SSH_CONTAINER_PORT:-2223}/" /etc/ssh/sshd_config
  fi

  echo "[TEMPLATE INFO] Starting ssh server on port ${SSH_CONTAINER_PORT:-2223}."
  # This runs in background, so the script will continue.
  if [ "${EUID}" -eq 0 ] || [ -n "${NO_SUDO_NEEDED}" ]; then
    /usr/sbin/sshd
  else
    echo "${PASSWD}" | sudo -S /usr/sbin/sshd
  fi

  # Make login shells cd to the project root.
  echo "cd ${PROJECT_ROOT_AT}" >> "${HOME}/.bash_profile"
  echo "cd ${PROJECT_ROOT_AT}" >> "${HOME}/.zprofile"
fi

####################
## PyCharm remote development server.
# You can set the env variable JETBRAINS_SERVER_AT to persist your JetBrains configuration and cache.
# You can set the env variable PYCHARM_IDE_AT to the location of the PyCharm binaries in your mounted storage.

# Workaround using symlinks when clusters do not allow to mount specific directories or files.
if [ -n "${JETBRAINS_SERVER_AT}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to PyCharm project config files."
  # Per-project server.
  # Create if doesn't exist.
  PROJECT_JETBRAINS_SERVER_AT="${JETBRAINS_SERVER_AT}/projects/${PROJECT_ROOT_AT}"
  mkdir -p "${JETBRAINS_SERVER_AT}"/dist
  mkdir -p "${PROJECT_JETBRAINS_SERVER_AT}/config"
  mkdir -p "${PROJECT_JETBRAINS_SERVER_AT}/local"
  mkdir -p "${PROJECT_JETBRAINS_SERVER_AT}/cache"
  mkdir -p "${HOME}/.config"
  mkdir -p "${HOME}/.local/share"
  mkdir -p "${HOME}/.cache"
  ln -s "${PROJECT_JETBRAINS_SERVER_AT}/config" "${HOME}/.config/JetBrains"
  ln -s "${PROJECT_JETBRAINS_SERVER_AT}/local" "${HOME}/.local/share/JetBrains"
  ln -s "${PROJECT_JETBRAINS_SERVER_AT}/cache" "${HOME}/.cache/JetBrains"
fi

if [ -n "${PYCHARM_IDE_AT}" ]; then
  # Check if directory exists.
  if [ ! -d "${JETBRAINS_SERVER_AT}/dist/${PYCHARM_IDE_AT}" ]; then
    echo "[TEMPLATE WARNING] The PyCharm IDE directory ${JETBRAINS_SERVER_AT}/dist/${PYCHARM_IDE_AT} does not exist."
    echo "[TEMPLATE WARNING] The IDE will not be started. This is okay if you're installing an IDE manually."
  else
    echo "[TEMPLATE INFO] Starting PyCharm remote development server."
    REMOTE_DEV_NON_INTERACTIVE=1 \
      "${JETBRAINS_SERVER_AT}/dist/${PYCHARM_IDE_AT}/bin/remote-dev-server.sh" run "${PROJECT_ROOT_AT}" \
      --ssh-link-host 127.0.0.1 \
      --ssh-link-user "${USER:-$(id -un)}" \
      --ssh-link-port "${SSH_FORWARD_PORT:-2223}" &
  fi
fi

####################
## VS Code remote development server.
# Workaround using symlinks when clusters do not allow to mount specific directories or files.

if [ -n "${VSCODE_SERVER_AT}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to VSCode server config files."
  # Per-project server.
  # Create if doesn't exist.
  PROJECT_VSCODE_SERVER_AT="${VSCODE_SERVER_AT}/projects${PROJECT_ROOT_AT}"
  mkdir -p "${PROJECT_VSCODE_SERVER_AT}"
  ln -s "${PROJECT_VSCODE_SERVER_AT}" "${HOME}/.vscode-server"
fi

####################
## Cursor remote development server.
# Same as VSCode up to naming

if [ -n "${CURSOR_SERVER_AT}" ]; then
  echo "[TEMPLATE INFO] Sym-linking to Cursor server config files."
  # Per-project server.
  # Create if doesn't exist.
  PROJECT_CURSOR_SERVER_AT="${CURSOR_SERVER_AT}/projects${PROJECT_ROOT_AT}"
  mkdir -p "${PROJECT_CURSOR_SERVER_AT}"
  ln -s "${PROJECT_CURSOR_SERVER_AT}" "${HOME}/.cursor-server"
fi

#####################
# Jupyter Lab server.
# Jupyter must be installed in the environment.

if [ -n "${JUPYTER_SERVER}" ]; then
  echo "[TEMPLATE INFO] Starting Jupyter Lab server."
  # Workaround to open zsh.
  SHELL=zsh \
    jupyter-lab --no-browser --port="${JUPYTER_PORT:-8887}" --notebook-dir="${PROJECT_ROOT_AT}" &
fi
