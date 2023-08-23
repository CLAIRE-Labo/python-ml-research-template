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
REGISTRY_HOSTNAME=docker.io
# EPFL-IC users should change the REGISTRY_HOSTNAME to ic-registry.epfl.ch.

### For running locally
CPU_OR_GPU=cpu
LOCAL_PROJECT_DIR=../../
LOCAL_DATA_DIR=../../_data
LOCAL_OUTPUTS_DIR=../../_outputs
LOCAL_WANDB_DIR=../../_wandb
WANDB_API_KEY=

####################
# Project-specific environment variables.
## Used to avoid writing paths multiple times and creating inconsistencies.
## You should not need to change anything below this line.
PROJECT_NAME=<project-name>
PACKAGE_NAME=<package_name>
PROJECT_ROOT=/opt/project
PROJECT_DIR=\${PROJECT_ROOT}/\${PROJECT_NAME}
DATA_DIR=\${PROJECT_ROOT}/data
OUTPUTS_DIR=\${PROJECT_ROOT}/outputs
WWANDB_DIR=\${PROJECT_ROOT}/wandb
IMAGE_NAME=\$REGISTRY_HOSTNAME/\${LAB_NAME}/\${PROJECT_NAME}/\${USR}
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
  echo "Created ${ENV_FILE}. Edit it to set your user-specific variables."
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
  # Build the image without creating a new container.
  # Examples:
  # ./template.sh build runtime
  # ./template.sh build dev
  check
  IMAGE="${1}-image"
  COMPOSE_DOCKER_CLI_BUILD=1 \
    DOCKER_BUILDKIT=1 \
    docker compose -p "${COMPOSE_PROJECT}" build "$IMAGE"
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
  docker compose -p "${COMPOSE_PROJECT}" run --rm "${SERVICE}" "${@:2}"
}

# Call the function passed as the first argument
"$@"
