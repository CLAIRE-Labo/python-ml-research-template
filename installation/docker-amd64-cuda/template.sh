#!/bin/bash
#
set -e

ENV_TEXT=$(
  cat <<-EOF
# All user-specific configurations are here.

## For building:
GRPID=$(id -g)
USRID=$(id -u)
GRP=$(id -gn)
# USR is used in the image name and must be lowercase.
# It's fine if your username is not lowercase, jut make it lowercase.
USR=$(id -un | tr "[:upper:]" "[:lower:]")
# PASSWD is not secret,
# it is only there to avoid running password-less sudo commands accidentally.
PASSWD=$(id -un)
# LAB_NAME will be the first component in the image path.
# It must be lowercase.
LAB_NAME=$(id -un | tr "[:upper:]" "[:lower:]")

#### For running locally
# You can find the acceleration options in the compose.yaml file
# by looking at the services with names dev-local-ACCELERATION.
PROJECT_ROOT_AT=$(realpath "$(pwd)"/../..)
ACCELERATION=cuda
WANDB_API_KEY=
# PyCharm-related. Fill after installing the IDE manually the first time.
PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4


####################
# Project-specific environment variables.
## Used to avoid writing paths multiple times and creating inconsistencies.
## You should not need to change anything below this line.
PROJECT_NAME=template-project-name
PACKAGE_NAME=template_package_name
IMAGE_NAME=\${LAB_NAME}/\${USR}/\${PROJECT_NAME}
IMAGE_PLATFORM=amd64-cuda
# The image name includes the USR to separate the images in an image registry.
# Its tag includes the platform for registries that don't hand multi-platform images for the same tag.
# You can also add a suffix to the platform e.g. -jax or -pytorch if you use different images for different environments/models etc.

EOF
)

## All variables below are read from the `.env` and `.project.env` files.
ENV_FILE=".env"

env() {
  # Creates the `.env` file.
  if [[ -f "${ENV_FILE}" ]]; then
    echo "[TEMPLATE ERROR] File ${ENV_FILE} already exists. Aborting."
    exit 1
  fi
  echo "${ENV_TEXT}" >"${ENV_FILE}"
  echo "Created the ${ENV_FILE} file. Edit it to set your user-specific variables."
}

check() {
  # Checks if the `.env` file exists.
  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "[TEMPLATE ERROR] File ${ENV_FILE} does not exist.
     Run ./template.sh env to create it, then edit it."
    exit 1
  fi
  source "${ENV_FILE}"
  COMPOSE_PROJECT="${PROJECT_NAME}-${IMAGE_PLATFORM}-${USR}"
}

edit_from_base() {
  FROM_BASE="${1}"
  if [ "${FROM_BASE}" == "from-python" ] || [ "${FROM_BASE}" == "from-scratch" ]; then
    rm -rf dependencies
    rm -f Dockerfile
    rm -f compose-base.yaml
    cp -r "${FROM_BASE}-template" dependencies
    mv dependencies/Dockerfile .
    mv dependencies/compose-base.yaml .
  else
    echo "[TEMPLATE ERROR] Please specify a valid from-base: from-python or from-scratch."
    exit 1
  fi
}

pull_generic() {
  # Pull the generic runtime and dev images.
  check
  PULL_IMAGE_NAME="${1}"
  if [ "${PULL_IMAGE_NAME}" == "" ]; then
    echo "[TEMPLATE ERROR] Please specify the name of the image to pull."
    echo "For example: ./template.sh pull ic-registry.epfl.ch/${LAB_NAME}/gaspar/${PROJECT_NAME}"
    echo "For example: ./template.sh pull docker.io/docker-username/${PROJECT_NAME}"
    exit 1
  fi

  docker pull "${PULL_IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-root"
  docker tag "${PULL_IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-root" "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-root"

  docker pull "${PULL_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-root"
  docker tag "${PULL_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-root" "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-root"
}

build_generic() {
  # Check that the files in the installation/ directory are all committed to git if running the build command.
  # The image uses the git commit as a tag to know which dependencies where installed.
  # Error if there are uncommitted changes.
  if [[ ${IGNORE_UNCOMMITTED} -ne 1 ]] && \
    [[ $(git status --porcelain | grep  "installation/" | grep -v -E "README|template.sh" -c) -ge 1 ]]; then
    echo "[TEMPLATE ERROR] There are uncommitted changes in the installation/ directory.
    Please commit them before building your generic and user image.
    The image uses the git commit as a tag to keep track of which dependencies where installed.
    If these change don't affect the build (e.g. README),
    feel free to just commit and ignore the rebuild."
    echo "Force ignoring this error with the flag --ignore-uncommitted."
    exit 1
  fi

  # Build the generic runtime and dev images and tag them with the current git commit.
  check
  docker compose -p "${COMPOSE_PROJECT}" build image-run-root
  docker compose -p "${COMPOSE_PROJECT}" build image-dev-root

  # Tag the images with the current git commit.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-root" "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-${GIT_COMMIT}-root"
  docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-root" "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-${GIT_COMMIT}-root"
}

build_user() {
  # Check that the files in the installation/ directory are all committed to git if running the build command.
  # The image uses the git commit as a tag to know which dependencies where installed.
  # Error if there are uncommitted changes.
  if [[ ${IGNORE_UNCOMMITTED} -ne 1 ]] && \
    [[ $(git status --porcelain | grep  "installation/" | grep -v -E "README|template.sh" -c) -ge 1 ]]; then
    echo "[TEMPLATE ERROR] There are uncommitted changes in the installation/ directory.
    Please commit them before building your generic and user image.
    The image uses the git commit as a tag to keep track of which dependencies where installed.
    If these change don't affect the build (e.g. README),
    feel free to just commit and ignore the rebuild."
    echo "Force ignoring this error with the flag --ignore-uncommitted."
    exit 1
  fi

  # Build the user runtime and dev images and tag them with the current git commit.
  check
  docker compose -p "${COMPOSE_PROJECT}" build image-run-user
  docker compose -p "${COMPOSE_PROJECT}" build image-dev-user

  # If the generic image has the current git tag, then the user image has been build from that tag.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  if [[ $(docker images --format '{{.Repository}}:${IMAGE_PLATFORM}-{{.Tag}}' |\
   grep -c "${GIT_COMMIT}") -ge 1 ]]; then
    docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-${USR}" "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-${GIT_COMMIT}-${USR}"
    docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-${USR}" "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-${GIT_COMMIT}-${USR}"
  fi
}

build() {
  build_generic
  build_user
}

push_usr_or_root() {
  check
  USR_OR_ROOT="${1}"
  PUSH_IMAGE_NAME="${2}"
  if [ "${PUSH_IMAGE_NAME}" == "" ]; then
    echo "[TEMPLATE ERROR] Please specify the complete name of the image to push."
    echo "For example: ./template.sh push docker.io/docker-username/template-project-name"
    echo "EPFL people can just do ./template.sh push IC or ./template.sh push RCP
      And it will be pushed to ic-registry.epfl.ch/${IMAGE_NAME}
      or registry.rcp.epfl.ch/${IMAGE_NAME}"
    exit 1
  elif [ "${PUSH_IMAGE_NAME}" == "IC" ]; then
    PUSH_IMAGE_NAME="ic-registry.epfl.ch/${IMAGE_NAME}"
  elif [ "${PUSH_IMAGE_NAME}" == "RCP" ]; then
    PUSH_IMAGE_NAME="registry.rcp.epfl.ch/${IMAGE_NAME}"
  fi

  docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-${USR_OR_ROOT}" \
  "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-${USR_OR_ROOT}"
  docker push "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-${USR_OR_ROOT}"

  docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-${USR_OR_ROOT}" \
  "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-${USR_OR_ROOT}"
  docker push "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-${USR_OR_ROOT}"

  # If the image has a git tag push it as well.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  if [[ $(docker images --format '{{.Repository}}:{{.Tag}}' |\
  grep "${GIT_COMMIT}-${USR_OR_ROOT}" -c) -ge 1 ]]; then
    docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-${GIT_COMMIT}-${USR_OR_ROOT}" \
      "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-run-${GIT_COMMIT}-${USR_OR_ROOT}"
    docker push "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-run-${GIT_COMMIT}-${USR_OR_ROOT}"

    docker tag "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-${GIT_COMMIT}-${USR_OR_ROOT}" \
      "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-${GIT_COMMIT}-${USR_OR_ROOT}"
    docker push "${PUSH_IMAGE_NAME}:${IMAGE_PLATFORM}-dev-${GIT_COMMIT}-${USR_OR_ROOT}"
  fi
}

push_generic() {
  check
  push_usr_or_root "root" "${1}"
}

push_user() {
  check
  push_usr_or_root "${USR}" "${1}"
}

push() {
  push_generic "${1}"
  push_user "${1}"
}

list_env() {
  # List the conda environment.
  check
  echo "[TEMPLATE INFO] Listing the dependencies in an empty container (nothing mounted)."
  echo "[TEMPLATE INFO] It's normal to see the warnings about missing PROJECT_ROOT_AT or acceleration options."
  echo "[TEMPLATE INFO] The idea is to see if all your dependencies have been installed."
  docker run --rm "${IMAGE_NAME}:${IMAGE_PLATFORM}-run-latest-root" zsh -c \
  "echo '[TEMPLATE INFO] Running mamba list';\
  if command -v mamba >/dev/null 2>&1; then mamba list; \
  else echo '[TEMPLATE INFO] conda not in the environment, skipping...'; fi;
  echo '[TEMPLATE INFO] Running pip list'; pip list"
}

empty_interactive() {
  # Start an interactive shell in an empty container.
  check
  echo "[TEMPLATE INFO] Starting an interactive shell in an empty container (nothing mounted)."
  echo "[TEMPLATE INFO] It's normal to see the warnings about missing PROJECT_ROOT_AT or acceleration options."
  echo "[TEMPLATE INFO] The idea is to see if all your dependencies have been installed."
  docker run --rm -it "${IMAGE_NAME}:${IMAGE_PLATFORM}-dev-latest-root"
}

run() {
  # Run a command in a new runtime container.
  # Usage:
  # ./template.sh run -e VAR1=VAL1 -e VAR2=VAL2 ... python -c "print('hello world')"
  check
  local env_vars=()
  local detach=()

  # Catch detach flag
  if [[ "$1" == "-d" ]]; then
    shift
    detach+=("-d")
  fi

  # Collect environment variables and commands dynamically
  while [[ "$1" == "-e" ]]; do
    env_vars+=("$1" "$2")  # Store environment variable flags and values as array elements
    shift 2
  done

  # Execute the docker command using array expansion for environment variables
  docker compose -p "${COMPOSE_PROJECT}" run --rm "${detach[@]}" "${env_vars[@]}" "run-local-${ACCELERATION}" "$@"
}

dev() {
  # Run a command in a new development container.
  # Usage:
  # ./template.sh dev -e VAR1=VAL1 -e VAR2=VAL2 -e SSH_SERVER=1 ... sleep infinity"
  check

  # Create the placeholder directories for remote development.
  touch ${HOME}/.template-gitconfig
  mkdir -p ${HOME}/.template-dev-vscode-server
  mkdir -p ${HOME}/.template-dev-jetbrains-server

  local env_vars=()
  local detach=()

  # Catch detach flag
  if [[ "$1" == "-d" ]]; then
    shift
    detach+=("-d")
  fi

  # Collect environment variables and commands dynamically
  while [[ "$1" == "-e" ]]; do
    env_vars+=("$1" "$2")  # Store environment variable flags and values as array elements
    shift 2
  done

  # Execute the docker command using array expansion for environment variables
  docker compose -p "${COMPOSE_PROJECT}" run --rm "${detach[@]}" "${env_vars[@]}" "dev-local-${ACCELERATION}" "$@"
}

get_runai_scripts() {
  # Rename the runai examples.
  # ./template.sh rename-runai-examples
  check
  cp -r "./EPFL-runai-setup/template-submit-examples/" "./EPFL-runai-setup/submit-scripts"
  for file in \
    "./EPFL-runai-setup/submit-scripts/first-steps.sh" \
    "./EPFL-runai-setup/submit-scripts/minimal.sh" \
    "./EPFL-runai-setup/submit-scripts/remote-development.sh" \
    "./EPFL-runai-setup/submit-scripts/unattended.sh" ; do
    sed -i.deleteme "s/moalla/${USR}/g" "$file" && rm "${file}.deleteme"
    sed -i.deleteme "s/claire-compute/${GRP}/g" "$file" && rm "${file}.deleteme"
    sed -i.deleteme "s/claire/${LAB_NAME}/g" "$file" && rm "${file}.deleteme"
  done
}

usage() {
  echo "Usage: $0 {env|pull_generic|build_generic|build_user|build|push_generic|push_user|push|list_env|empty_interactive|run|dev|get_runai_scripts}"

  # Describe each function with its arguments.
  echo "env: Create the .env file with the user-specific variables."
  echo "pull_generic IMAGE_NAME: Pull the generic runtime and dev images."
  echo "build_generic: Build the generic runtime and dev images."
  echo "build_user: Build the user runtime and dev images."
  echo "build: Build the generic and user runtime and dev images."
  echo "push_generic IMAGE_NAME: Push the generic runtime and dev images."
  echo "push_user IMAGE_NAME: Push the user runtime and dev images."
  echo "push IMAGE_NAME: Push the generic and user runtime and dev images."
  echo "list_env: List the pip/conda environment."
  echo "empty_interactive: Start an interactive shell in an empty container."
  echo "run -e VAR1=VAL1 -e VAR2=VAL2 ... COMMAND: Run a command in a new runtime container."
  echo "dev -e VAR1=VAL1 -e VAR2=VAL2 ... COMMAND: Run a command in a new development container."
  echo "get_runai_scripts: Rename the runai examples."
}

if [ $# -eq 0 ]; then
    usage
else
  # catch the flags
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --ignore-uncommitted)
      IGNORE_UNCOMMITTED=1
      shift
      ;;
  esac
  # run the command
  "$@"
fi
