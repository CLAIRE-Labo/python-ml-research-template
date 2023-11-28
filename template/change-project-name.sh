# This script allows to replace the template variables with your project ones.
set -eo pipefail
source template/template-variables.env

# Iterate through all files in the project except dot directories and this directory.
for file in $(find . -type f -not -path './template/*' -not -path '*/\.*' -not -path '*/__*__/*'); do
  # .deleteme is a trick to make sed work the same way on both Linux and OSX.
  # https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux
  sed -i.deleteme "s/${OLD_PROJECT_NAME}/${NEW_PROJECT_NAME}/g" "${file}"
  sed -i.deleteme "s/${OLD_PACKAGE_NAME}/${NEW_PACKAGE_NAME}/g" "$file"
  sed -i.deleteme "s/python=${OLD_PYTHON_VERSION}/python=${NEW_PYTHON_VERSION}/g" "$file"
  sed -i.deleteme "s/python${OLD_PYTHON_VERSION}/python${NEW_PYTHON_VERSION}/g" "$file"
  sed -i.deleteme "s/Python ${OLD_PYTHON_VERSION}/Python ${NEW_PYTHON_VERSION}/g" "$file"
  sed -i.deleteme "s/requires-python = \">=${OLD_PYTHON_VERSION}\"/requires-python = \">=${NEW_PYTHON_VERSION}\"/g" "$file"
  # Delete the .deleteme file if it exists.
  rm -f "$file.deleteme"
done

if [ "${NEW_PACKAGE_NAME}" != "${OLD_PACKAGE_NAME}" ]; then
  mv "src/${OLD_PACKAGE_NAME}" src/"${NEW_PACKAGE_NAME}"
fi
