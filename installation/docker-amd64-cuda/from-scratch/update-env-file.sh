# Records the current environment to a file.
# Packages installed from GitHub with pip install <git url> will not be recorded
# properly (i.e. the link can be omitted and just replaced with the version).
# In that case, you have to update this file to add commands that
# will fix the environment file. (you could also just edit it manually afterwards).

ENV_FILE="${PROJECT_ROOT_AT}"/installation/docker-amd64-cuda/dependencies/environment.yml
# Export, but delete the package itself as it's installed at runtime.
# This is because it is only available after mounting the code.
mamba env export --no-builds | sed "/${PROJECT_NAME}==.*/d" >"$ENV_FILE"
