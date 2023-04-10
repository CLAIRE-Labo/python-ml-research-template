# This script allows to replace the template variables with your project ones.

source template/template_variables.sh

mv "src/package_name/" "src/${PACKAGE_NAME}"
OSX64_DIR="installation/osx-arm64"
AMD_64_DIR="installation/amd64"
for file in \
  "$OSX64_DIR/update_env_file.sh"\
  "$AMD64_DIR/dependencies/update_env_file.sh"\
  "$OSX64_DIR/README.md"\
  "$AMD64_DIR/README.md"\
  "$OSX64_DIR/environment.yml"\
  "$AMD64_DIR/dependencies/environment.yml"\
  "$AMD64_DIR/docker-compose.yml"\
  pyproject.toml
do
  sed -i '' "s/<project-name>/${PROJECT_NAME}/g" $file
  sed -i '' "s/<package_name>/${PACKAGE_NAME}/g" $file
  sed -i '' "s/<python-version>/${PYTHON_VERSION}/g" $file
done
