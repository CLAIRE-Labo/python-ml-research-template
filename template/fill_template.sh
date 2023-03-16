# This script allows to replace the template variables with your project ones.

source template/template_variables.sh

mv "src/package_name/" "src/${PACKAGE_NAME}"
OSX64_DIR="installation/osx-arm64"
for file in "$OSX64_DIR/update_env_file.sh" "$OSX64_DIR/README.md" "$OSX64_DIR/environment.yml" pyproject.toml
do
  sed -i '' "s/<project-name>/${PROJECT_NAME}/g" $file
  sed -i '' "s/<package_name>/${PACKAGE_NAME}/g" $file
  sed -i '' "s/<python-version>/${PYTHON_VERSION}/g" $file
done
