# A workaround to define multiline text.
define ENV_TEXT
# All user-specific configurations are here.

## For building:
GID=$(shell id -g)
UID=$(shell id -u)
GRP=$(shell id -gn)
USR=$(shell id -un)
# PASSWD is not secret,
# it is only there to avoid running password-less sudo commands accidentally.
PASSWD=$(shell id -un)
LAB_NAME=$(shell id -un)
IMAGE_TAG=latest
WANDB_API_KEY=0

## For running:
SERVICE=image-only
### For running locally
LOCAL_CODE_DIR=../../code
LOCAL_DATA_DIR=../../data
LOCAL_OUTPUTS_DIR=../../outputs

####################
# Project-specific environment variables.
## Used to avoid writing paths multiple times and creating unconsistencies.
## You should not need to change anything below this line.
PROJECT_NAME=<project-name>
PACKAGE_NAME=<package_name>
PROJECT_ROOT=/opt/project
CODE_DIR=$PROJECT_ROOT/code
DATA_DIR=$PROJECT_ROOT/data
OUTPUTS_DIR=$PROJECT_ROOT/outputs
endef
export ENV_TEXT

# All variables below are read from the `.env` and `.project.env` files.
ENV_FILE = .env
-include ${ENV_FILE}

IMAGE_NAME = ${LAB_NAME}/${PROJECT_NAME}:${USR}
COMPOSE_PROJECT = $(shell echo ${PROJECT_NAME}-${USR} | tr "[:upper:]" "[:lower:]")
command = python --version

.PHONY: env check build up logs exec run start down
env:  # Creates the `.env` file if it does not exist.
	@test -f ${ENV_FILE} || printf "$$ENV_TEXT" >> ${ENV_FILE}

check:  # Checks if the `.env` file exists.
	@if [ ! -f "${ENV_FILE}" ]; then \
		printf "File \`${ENV_FILE}\` does not exist. " && \
		printf "Run \`make env\` to create \`${ENV_FILE}\`.\n" && \
		exit 1; \
	fi

# TODO: are those COMPOSE_BUILDKIT=1 and DOCKER_BUILDKIT=1 needed?
build: check # Build the image without creating a new container.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${COMPOSE_PROJECT} build ${SERVICE}
up: check  # Start service. Creates a new container from the image.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${COMPOSE_PROJECT} up -d ${SERVICE}
logs:  # Show logs from the service.
	docker compose -p ${COMPOSE_PROJECT} logs ${SERVICE}
exec:	# Enter interactive shell.
	DOCKER_BUILDKIT=1 docker compose -p ${COMPOSE_PROJECT} exec ${SERVICE} zsh
run:	# Run a command in a new container.
	docker compose -p ${COMPOSE_PROJECT} run --rm ${SERVICE} ${command}
# Useful if the previous container must not be deleted.
start:	# Start a stopped service without recreating the container.
	docker compose -p ${COMPOSE_PROJECT} start ${SERVICE}
down:	# Shut down the service and delete containers, volumes, networks, etc.
	docker compose -p ${COMPOSE_PROJECT} down
