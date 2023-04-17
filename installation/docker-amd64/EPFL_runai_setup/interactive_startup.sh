####################
# Open ssh server.
echo "${PASSWD}" | sudo -S /usr/sbin/sshd

####################
## PyCharm remote development server.
# Set the env variables
# PYCHARM_IDE=1 and PYCHARM_IDE_LOCATION to the location of the PyCharm binaries in your NFS.
# Must have the binaries in your NFS.

## The port on your local machine that will be forwarded to the remote server.
SSH_FORWARD_PORT=${SSH_FORWARD_PORT:-2222}

REMOTE_DEV_NON_INTERACTIVE=1 \
"${PYCHARM_IDE_LOCATION}"/bin/remote-dev-server.sh \
  run "${PROJECT_ROOT}" \
  --ssh-link-host 127.0.0.1 \
  --ssh-link-user "${USER}" \
  --ssh-link-port "${SSH_FORWARD_PORT}"

####################
# VScode remote development server.
# TODO.
