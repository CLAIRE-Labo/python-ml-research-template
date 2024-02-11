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

## For running locally
# You can find the acceleration options in the compose.yaml file
# by looking at the services with names dev-local-ACCELERATION.
PROJECT_ROOT_AT=/project/template-project-name
ACCELERATION=cpu
WANDB_API_KEY=

####################
# Project-specific environment variables.
## Used to avoid writing paths multiple times and creating inconsistencies.
## You should not need to change anything below this line.
PROJECT_NAME=template-project-name
PACKAGE_NAME=template_package_name
IMAGE_NAME=\${LAB_NAME}/\${USR}/\${PROJECT_NAME}
# The image name also includes the USR
# to avoid conflicts between users using the same build machine
# Or sharing repositories. (Duplicate images with different names will still be stored only once.)
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
  COMPOSE_PROJECT="${PROJECT_NAME}-${USR}"

  # Check that the files in the installation/ directory are all committed to git.
  # The image uses the git commit as a tag to know which dependencies where installed.
  # Error if there are uncommitted changes.
  if [[ $(git status --porcelain | grep  "installation/" | grep -v -E "README|template.sh" -c)\
    -ge 1 ]]; then
    echo "[TEMPLATE ERROR] There are uncommitted changes in the installation/ directory.
    Please commit them before building your generic and user image.
    The image uses the git commit as a tag to keep track of which dependencies where installed.
    If these change don't affect the build (e.g. README),
    feel free to just commit and ignore the rebuild."
    exit 1
  fi
}

edit_from_base() {
  FROM_BASE="${1}"
  if [ "${FROM_BASE}" == "from-python" ] || [ "${FROM_BASE}" == "from-scratch" ]; then
    rm -rf dependencies
    rm -f Dockerfile
    rm -f compose-base.yaml
    cp -r "${FROM_BASE}" dependencies
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
    echo "For example: ./template.sh pull ic-registry.epfl.ch/${LAB_NAME}/moalla/${PROJECT_NAME}"
    echo "For example: ./template.sh pull docker.io/skandermoalla/${PROJECT_NAME}"
    exit 1
  fi

  docker pull "${PULL_IMAGE_NAME}:run-latest-root"
  docker tag "${PULL_IMAGE_NAME}:run-latest-root" "${IMAGE_NAME}:run-latest-root"

  docker pull "${PULL_IMAGE_NAME}:dev-latest-root"
  docker tag "${PULL_IMAGE_NAME}:dev-latest-root" "${IMAGE_NAME}:dev-latest-root"
}

build_generic() {
  # Build the generic runtime and dev images and tag them with the current git commit.
  check
  docker compose -p "${COMPOSE_PROJECT}" build image-run-root
  docker compose -p "${COMPOSE_PROJECT}" build image-dev-root

  # Tag the images with the current git commit.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  docker tag "${IMAGE_NAME}:run-latest-root" "${IMAGE_NAME}:run-${GIT_COMMIT}-root"
  docker tag "${IMAGE_NAME}:dev-latest-root" "${IMAGE_NAME}:dev-${GIT_COMMIT}-root"
}

build_user() {
  # Build the user runtime and dev images and tag them with the current git commit.
  check
  docker compose -p "${COMPOSE_PROJECT}" build image-run-user
  docker compose -p "${COMPOSE_PROJECT}" build image-dev-user

  # If the generic image has the current git tag, then the user image has been build from that tag.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  if [[ $(docker images --format '{{.Repository}}:{{.Tag}}' |\
   grep -c "${GIT_COMMIT}") -ge 1 ]]; then
    docker tag "${IMAGE_NAME}:run-latest-${USR}" "${IMAGE_NAME}:run-${GIT_COMMIT}-${USR}"
    docker tag "${IMAGE_NAME}:dev-latest-${USR}" "${IMAGE_NAME}:dev-${GIT_COMMIT}-${USR}"
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
    echo "For example: ./template.sh push docker.io/skandermoalla/template-project-name"
    echo "EPFL people can just do ./template.sh push IC or ./template.sh push RCP
      And it will be pushed to ic-registry.epfl.ch/${IMAGE_NAME}
      or registry.rcp.epfl.ch/${IMAGE_NAME}"
    exit 1
  elif [ "${PUSH_IMAGE_NAME}" == "IC" ]; then
    PUSH_IMAGE_NAME="ic-registry.epfl.ch/${IMAGE_NAME}"
  elif [ "${PUSH_IMAGE_NAME}" == "RCP" ]; then
    PUSH_IMAGE_NAME="registry.rcp.epfl.ch/${IMAGE_NAME}"
  fi

  docker tag "${IMAGE_NAME}:run-latest-${USR_OR_ROOT}" \
  "${PUSH_IMAGE_NAME}:run-latest-${USR_OR_ROOT}"
  docker push "${PUSH_IMAGE_NAME}:run-latest-${USR_OR_ROOT}"

  docker tag "${IMAGE_NAME}:dev-latest-${USR_OR_ROOT}" \
  "${PUSH_IMAGE_NAME}:dev-latest-${USR_OR_ROOT}"
  docker push "${PUSH_IMAGE_NAME}:dev-latest-${USR_OR_ROOT}"

  # If the image has a git tag push it as well.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  if [[ $(docker images --format '{{.Repository}}:{{.Tag}}' |\
  grep "${GIT_COMMIT}-${USR_OR_ROOT}" -c) -ge 1 ]]; then
    docker tag "${IMAGE_NAME}:run-${GIT_COMMIT}-${USR_OR_ROOT}" \
      "${PUSH_IMAGE_NAME}:run-${GIT_COMMIT}-${USR_OR_ROOT}"
    docker push "${PUSH_IMAGE_NAME}:run-${GIT_COMMIT}-${USR_OR_ROOT}"

    docker tag "${IMAGE_NAME}:dev-${GIT_COMMIT}-${USR_OR_ROOT}" \
      "${PUSH_IMAGE_NAME}:dev-${GIT_COMMIT}-${USR_OR_ROOT}"
    docker push "${PUSH_IMAGE_NAME}:dev-${GIT_COMMIT}-${USR_OR_ROOT}"
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

up() {
  # Start service.
  # Creates a detached container from the development image.
  # ./template.sh up
  check
  docker compose -p "${COMPOSE_PROJECT}" up -d "dev-local-${ACCELERATION}"
}

down() {
  # Shut down the service and delete containers, volumes, networks, etc.
  check
  docker compose -p "${COMPOSE_PROJECT}" down
}

logs() {
  # Show logs from the service.
  # ./template.sh logs
  check
  docker compose -p "${COMPOSE_PROJECT}" logs "dev-local-${ACCELERATION}"
}

shell() {
  # Enter interactive shell in the development container.
  check
  docker compose -p "${COMPOSE_PROJECT}" exec "dev-local-${ACCELERATION}" zsh
}

stop() {
  # Stop the service without deleting the container.
  check
  docker compose -p "${COMPOSE_PROJECT}" stop "dev-local-${ACCELERATION}"
}

start() {
  # Start a stopped service without recreating the container.
  check
  docker compose -p "${COMPOSE_PROJECT}" start "dev-local-${ACCELERATION}"
}

run() {
  # Run a command in a new runtime container.
  # ./template.sh run python -c "print('hello world')"
  check
  docker compose -p "${COMPOSE_PROJECT}" run --rm "run-local-${ACCELERATION}" "${@:1}"
}

list_env() {
  # List the conda environment.
  check
  docker run --rm "${IMAGE_NAME}:run-latest-root" pip list
  docker run --rm "${IMAGE_NAME}:run-latest-root" mamba list
}

empty_interactive() {
  # Start an interactive shell in an empty container.
  check
  docker run --rm -it "${IMAGE_NAME}:dev-latest-root"
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

# Call the function passed as the first argument
"$@"
