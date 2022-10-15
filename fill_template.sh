# This script allows to replace the template variables with your project ones.

# Template variables.
# <project-name>
PROJECT_NAME="project-name" # Hyphen as word separator.

# <python-version>
PYTHON_VERSION="3.x"

PACKAGE_NAME="package_name" # Underscore as word separator.
# End of template variables.

mv "src/package_name/" "src/${PACKAGE_NAME}"
# .bak is a workaround for sed to work on GNU and BSD/Mac.
# (https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux)
sed -i.bak "s/<project-name>/${PROJECT_NAME}/g" installation/conda/create_env.sh && rm installation/conda/create_env.sh.bak
sed -i.bak "s/<project-name>/${PROJECT_NAME}/g" pyproject.toml && rm pyproject.toml.bak
sed -i.bak "s/<python-version>/${PYTHON_VERSION}/g" installation/conda/create_env.sh && rm installation/conda/create_env.sh.bak
sed -i.bak "s/<python-version>/${PYTHON_VERSION}/g" pyproject.toml && rm pyproject.toml.bak

