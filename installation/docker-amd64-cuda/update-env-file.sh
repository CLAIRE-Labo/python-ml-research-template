# Records the current environment to a file.
# Packages installed from GitHub with pip install <git url> will not be recorded
# properly (i.e. the link will be omitted and just replaced with the version).
# In that case, you have to update this file to add commands that
# will fix the environment file. (you could also just edit it manually afterwards).

ENV_FILE="${PROJECT_ROOT_AT}"/installation/docker-amd64-cuda/requirements.txt
pip list --exclude-editable --format freeze > "${ENV_FILE}"
