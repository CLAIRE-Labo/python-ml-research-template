ENV_FILE="${PROJECT_DIR}"/installation/docker-amd64/dependencies/environment.yml
# Export, but delete the package itself as it's installed at runtime.
# This is because it is only available after mounting the code.
mamba env export --no-builds | sed "/.*- ${PROJECT_NAME}==.*/d" >"$ENV_FILE"
