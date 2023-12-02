# Records the current environment to a file.
# Packages installed from GitHub with pip install <git url> will not be recorded
# properly (i.e. the link can be omitted and just replaced with the version).
# In that case, you have to update this file to add commands that
# will fix the environment file. (you could also just edit it manually afterwards).

ENV_FILE="${PROJECT_ROOT_AT}"/installation/docker-amd64-cuda/dependencies/requirements.txt
# Export, but delete the package itself as it's installed at runtime.
# This is because it is only available after mounting the code.
# Also remove the details of all packages installed from files prefixed with @.
pip freeze \
  | sed "/-e.*/d" \
  | sed "s/ @.*//g" \
  > "${ENV_FILE}"
