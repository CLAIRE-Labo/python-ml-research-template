#!/bin/bash

# This script allows to replace the template variables with your project ones.
set -eo pipefail
source template/template_variables.env

OSX64_DIR="installation/osx-arm64"
AMD64_DIR="installation/docker-amd64"

for file in \
  "reproducibility_scripts/some_experiment.sh" \
  "README.md" \
  "pyproject.toml" \
  "LICENSE" \
  ".pre-commit-config.yaml" \
  "src/package_name/main.py" \
  "src/package_name/utils/__init__.py" \
  "$OSX64_DIR/README.md" \
  "$OSX64_DIR/update_env_file.sh" \
  "$OSX64_DIR/environment.yml" \
  "$AMD64_DIR/dependencies/environment.yml" \
  "$AMD64_DIR/dependencies/update_env_file.sh" \
  "$AMD64_DIR/README.md" \
  "$AMD64_DIR/template.sh"; do
  sed -i.deleteme "s/<project-name>/${PROJECT_NAME}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/<package_name>/${PACKAGE_NAME}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/<python-version>/${PYTHON_VERSION}/g" "$file" && rm "${file}.deleteme"
  # .deleteme is a trick to make sed work on both Linux and OSX.
  # https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux
done

mv "src/package_name/" "src/${PACKAGE_NAME}"
