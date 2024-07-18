#!/bin/bash

# The base entrypoint (from the base image) should exec the command it receives otherwise this will break
# the signal handling.
# (Otherwise, you should source it, assuming then run with the same shell, then exec /opt/template-entrypoints/entrypoint.sh.)
# In the end all variables exported should be present and the command given by the user should run with PID 1.

# On Slurm, if the entrypoint has to be called as a script, (not as an entrypoint),
# The number of times the entrypoint is called should match the number of containers created.
if [ -n "${SLURM_ONE_ENTRYPOINT_SCRIPT_PER_JOB}" ] && [ "${SLURM_PROCID}" -gt 0 ]; then
  echo "[TEMPLATE INFO] Running the entrypoing only once for the job."
  echo "[TEMPLATE INFO] Skipping entrypoints on SLURM_PROCID ${SLURM_PROCID}."
  exec "$@"
fi
if [ -n "${SLURM_ONE_ENTRYPOINT_SCRIPT_PER_NODE}" ] && [ "${SLURM_LOCALID}" -gt 0 ]; then
  echo "[TEMPLATE INFO] Running the entrypoint once per node."
  echo "[TEMPLATE INFO] Skipping entrypoints on SLURM_PROCID ${SLURM_PROCID}."
  exec "$@"
fi

# Do this if the entrypoint execs the command it receives (every entrypoint should do this).
if [ -n "${BASE_ENTRYPOINT_EXECS}" ] && [ "${BASE_ENTRYPOINT_EXECS}" -eq 1 ] && [ -n "${BASE_ENTRYPOINT}" ]; then
  echo "[TEMPLATE INFO] execing the base image's entrypoint ${BASE_ENTRYPOINT} which will then exec the template's entrypoint."
  exec "${BASE_ENTRYPOINT}" /opt/template-entrypoints/entrypoint.sh "$@"
else
  if [ -n "${BASE_ENTRYPOINT}" ]; then
    echo "[TEMPLATE INFO] Sourcing the base image's entrypoint ${BASE_ENTRYPOINT} then execing the template's entrypoint."
    source "${BASE_ENTRYPOINT}" || { echo "Failed to source ${BASE_ENTRYPOINT}"; exit 1; }
    exec /opt/template-entrypoints/entrypoint.sh "$@"
  else
    echo "[TEMPLATE INFO] Execing the template's entrypoint."
    exec /opt/template-entrypoints/entrypoint.sh "$@"
  fi
fi
