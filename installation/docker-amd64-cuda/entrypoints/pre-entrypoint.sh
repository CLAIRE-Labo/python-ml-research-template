#!/bin/bash -l
# Runs as login shell to setup the environment (if conda for example, or other workarounds)

# The base entrypoint (from the base image) should exec the command it receives otherwise this will break
# the signal handling.
# (Otherwise, you should source it, assuming then run with the same shell, then exec /opt/template-entrypoints/entrypoint.sh.)
# In the end all variables exported should be present and the command given by the user should run with PID 1.

# Do this if the entrypoint execs the command it receives (every entrypoint should do this).
if [ "${BASE_ENTRYPOINT_EXECS}" -eq 1 ] && [ -n "${BASE_ENTRYPOINT}" ]; then
  echo "[TEMPLATE INFO] execing the base entrypoint ${BASE_ENTRYPOINT} which will exec the template's entrypoint."
  exec "${BASE_ENTRYPOINT}" /opt/template-entrypoints/entrypoint.sh "$@"
else
  if [ -n "${BASE_ENTRYPOINT}" ]; then
    echo "[TEMPLATE INFO] Sourcing the base entrypoint ${BASE_ENTRYPOINT} then execing the template's entrypoint."
    source "${BASE_ENTRYPOINT}" || { echo "Failed to source ${BASE_ENTRYPOINT}"; exit 1; }
    exec /opt/template-entrypoints/entrypoint.sh "$@"
  else
    echo "[TEMPLATE INFO] Execing the template's entrypoint."
    exec /opt/template-entrypoints/entrypoint.sh "$@"
  fi
fi
