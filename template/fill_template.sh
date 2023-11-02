#!/bin/bash

# This script allows to replace the template variables with your project ones.
set -eo pipefail
source template/template_variables.env

OSX64_DIR="installation/osx-arm64"
AMD64_DIR="installation/docker-amd64"
PACKAGE_DIR="src/template_package_name"

# Starting from the bottom of the explorer.
for file in \
  "README.md" \
  "pyproject.toml" \
  "LICENSE" \
  ".pre-commit-config.yaml" \
  "$PACKAGE_DIR/some_experiment.py" \
  "$PACKAGE_DIR/utils/__init__.py" \
  "$PACKAGE_DIR/configs/wandb.yaml" \
  "_data/README.md" \
  "reproducibility_scripts/some_experiment.sh" \
  "$OSX64_DIR/README.md" \
  "$OSX64_DIR/update_env_file.sh" \
  "$OSX64_DIR/environment.yml" \
  "$AMD64_DIR/template.sh" \
  "$AMD64_DIR/README.md" \
  "$AMD64_DIR/EPFL-runai-setup/submit-examples/first_steps.sh" \
  "$AMD64_DIR/EPFL-runai-setup/submit-examples/minimal.sh" \
  "$AMD64_DIR/EPFL-runai-setup/submit-examples/remote_development.sh" \
  "$AMD64_DIR/EPFL-runai-setup/submit-examples/unattended.sh" \
  "$AMD64_DIR/EPFL-runai-setup/README.md" \
  "$AMD64_DIR/dependencies/environment.yml" \
  "$AMD64_DIR/dependencies/update_env_file.sh" ; do
  sed -i.deleteme "s/template-project-name/${PROJECT_NAME}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/template_package_name/${PACKAGE_NAME}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/python=3.10/python=${PYTHON_VERSION}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/python3.10/python${PYTHON_VERSION}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/Python 3.10/Python ${PYTHON_VERSION}/g" "$file" && rm "${file}.deleteme"
  sed -i.deleteme "s/requires-python = \">=3.10\"/requires-python = \">=${PYTHON_VERSION}\"/g" "$file" \
    && rm "${file}.deleteme"
    # .deleteme is a trick to make sed work on both Linux and OSX.
    # https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux
done

mv "src/template_package_name/" "src/${PACKAGE_NAME}"
