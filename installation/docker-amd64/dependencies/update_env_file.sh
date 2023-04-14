# Export, but delete the package itself as it's installed at runtime.
# This is because it is only available after mounting the code.
mamba env export | sed "/.*- ${PROJECT_NAME}==.*/d" > ./installation/docker-amd64/dependencies/environment.yml


