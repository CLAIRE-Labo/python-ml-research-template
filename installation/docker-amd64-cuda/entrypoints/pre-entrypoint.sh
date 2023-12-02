#!/bin/bash
# The original entrypoint should exec the command it receives otherwise this will break
# the signal handling.
# The end command should run with PID 1.
exec "${BASE_ENTRYPOINT}" zsh /opt/template-entrypoints/entrypoint.sh "$@"
