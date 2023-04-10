# Startup script for remote development.

source "${EPFL_CONFIG_DIR}"/setup.sh

# Open ssh server.
echo "${PASSWD}" | sudo -S /usr/sbin/sshd

# PyCharm remote development server. Delete if not using.

# Must have the binaries in your NFS.
# Here it is in /mlodata1/${USER}/remote_development/pycharm
PYCHARM_IDE_LOCATION="/mlodata1/${USER}/remote_development/pycharm"
# The port on your local machine that will be forwarded to the remote server.
SSH_FORWARD_PORT=2222

REMOTE_DEV_NON_INTERACTIVE=1 \
"$PYCHARM_IDE_LOCATION"/bin/remote-dev-server.sh \
  run "${PROJECT_ROOT}"\
  --ssh-link-host 127.0.0.1\
  --ssh-link-user "${USER}"\
  --ssh-link-port $SSH_FORWARD_PORT

# VScode remote development server. Delete if not using.

# Must have the binaries in your NFS.
# Here it is in /mlodata1/${USER}/remote_development/vscode
VSCODE_IDE_LOCATION="/mlodata1/${USER}/remote_development/vscode"

