#!/bin/bash

ENV_TEXT=$(
  cat <<-EOF
# All user-specific configurations are here.

## For building:
GRPID=$(id -g)
USRID=$(id -u)
GRP=$(id -gn)
USR=$(id -un)
# PASSWD is not secret,
# it is only there to avoid running password-less sudo commands accidentally.
PASSWD=$(id -un)
LAB_NAME=$(id -un)

### For running locally
CPU_OR_GPU=cpu
LOCAL_PROJECT_DIR=../../
LOCAL_DATA_DIR=../../_data
# If your datasets are spread across multiple filesystems you can mount them individually.
# Specify
# LOCAL_DATASET_1_DIR=/somewhere/dataset_1
# LOCAL_DATASET_2_DIR=/somewhere/dataset_2
# And use the LOCAL_DATASET_I variables in the compose.yaml file instead of the LOCAL_DATA_DIR.
LOCAL_OUTPUTS_DIR=../../_outputs
LOCAL_WANDB_DIR=../../_wandb
WANDB_API_KEY=

####################
# Project-specific environment variables.
## Used to avoid writing paths multiple times and creating inconsistencies.
## You should not need to change anything below this line.
PROJECT_NAME=template-project-name
PACKAGE_NAME=template_package_name
PROJECT_ROOT=/opt/project
PROJECT_DIR=\${PROJECT_ROOT}/\${PROJECT_NAME}
DATA_DIR=\${PROJECT_ROOT}/data
OUTPUTS_DIR=\${PROJECT_ROOT}/outputs
WWANDB_DIR=\${PROJECT_ROOT}/wandb
IMAGE_NAME=\${LAB_NAME}/\${PROJECT_NAME}/\${USR}
EOF
)

## All variables below are read from the `.env` and `.project.env` files.
ENV_FILE=".env"

env() {
  # Creates the `.env` file.
  if [[ -f "${ENV_FILE}" ]]; then
    echo "File ${ENV_FILE} already exists. Aborting."
    exit 1
  fi
  echo "${ENV_TEXT}" >"${ENV_FILE}"
  echo "Created the ${ENV_FILE} file. Edit it to set your user-specific variables."
}

check() {
  # Checks if the `.env` file exists.
  if [[ ! -f "${ENV_FILE}" ]]; then
    echo "File ${ENV_FILE} does not exist. Run ./template.sh env to create it, then edit it."
    exit 1
  fi
  source "${ENV_FILE}"
  COMPOSE_PROJECT=$(echo "${PROJECT_NAME}-${USR}" | tr "[:upper:]" "[:lower:]")
}

build() {
  # Build the runtime and dev images and tag them with the current git commit.
  # ./template.sh build
  check
  COMPOSE_DOCKER_CLI_BUILD=1 \
    DOCKER_BUILDKIT=1 \
    docker compose -p "${COMPOSE_PROJECT}" build runtime-image
  COMPOSE_DOCKER_CLI_BUILD=1 \
    DOCKER_BUILDKIT=1 \
    docker compose -p "${COMPOSE_PROJECT}" build dev-image

  # Tag the images with the current git commit.
  GIT_COMMIT=$(git rev-parse --short HEAD)
  docker tag "${IMAGE_NAME}:latest-runtime" "${IMAGE_NAME}:${GIT_COMMIT}-runtime"
  docker tag "${IMAGE_NAME}:latest-dev" "${IMAGE_NAME}:${GIT_COMMIT}-dev"
}

push() {
  # Push the runtime and dev image to a specified registry.
  # ./template.sh push registry_hostname
  # Pushes the latest and current git commit images.
  check
  REGISTRY_HOSTNAME="${1}"
  if [ "${REGISTRY_HOSTNAME}" == "" ]; then
    echo "Please specify a registry hostname."
    exit 1
  fi
  if [ "${REGISTRY_HOSTNAME}" == "IC" ]; then
    REGISTRY_HOSTNAME="ic-registry.epfl.ch"
  fi
  if [ "${REGISTRY_HOSTNAME}" == "RCP" ]; then
    REGISTRY_HOSTNAME="registry.rcp.epfl.ch"
  fi

  GIT_COMMIT=$(git rev-parse --short HEAD)
  docker tag "${IMAGE_NAME}:latest-runtime" "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:latest-runtime"
  docker tag "${IMAGE_NAME}:latest-dev" "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:latest-dev"
  docker tag "${IMAGE_NAME}:${GIT_COMMIT}-runtime" "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:${GIT_COMMIT}-runtime"
  docker tag "${IMAGE_NAME}:${GIT_COMMIT}-dev" "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:${GIT_COMMIT}-dev"
  docker push "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:latest-runtime"
  docker push "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:latest-dev"
  docker push "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:${GIT_COMMIT}-runtime"
  docker push "${REGISTRY_HOSTNAME}/${IMAGE_NAME}:${GIT_COMMIT}-dev"
}


up() {
  # Start service.
  # Creates a detached container from the development image.
  # ./template.sh up
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  COMPOSE_DOCKER_CLI_BUILD=1 \
    DOCKER_BUILDKIT=1 \
    docker compose -p "${COMPOSE_PROJECT}" up -d "$SERVICE"
}

down() {
  # Shut down the service and delete containers, volumes, networks, etc.
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  docker compose -p "${COMPOSE_PROJECT}" down
}

logs() {
  # Show logs from the service.
  # ./template.sh logs
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  docker compose -p "${COMPOSE_PROJECT}" logs "$SERVICE"
}

shell() {
  # Enter interactive shell in the development container.
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  DOCKER_BUILDKIT=1 docker compose -p "${COMPOSE_PROJECT}" exec "${SERVICE}" zsh
}

stop() {
  # Stop the service without deleting the container.
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  docker compose -p "${COMPOSE_PROJECT}" stop "${SERVICE}"
}

start() {
  # Start a stopped service without recreating the container.
  check
  SERVICE="dev-local-${CPU_OR_GPU}"
  docker compose -p "${COMPOSE_PROJECT}" start "${SERVICE}"
}

run() {
  # Run a command in a new runtime container.
  # ./template.sh run python -c "print('hello world')"
  check
  SERVICE="runtime-local-${CPU_OR_GPU}"
  docker compose -p "${COMPOSE_PROJECT}" run --rm "${SERVICE}" "${@:1}"
}

# Call the function passed as the first argument
"$@"
