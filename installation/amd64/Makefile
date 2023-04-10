GID = $(shell id -g)
UID = $(shell id -u)
GRP = $(shell id -gn)
USR = $(shell id -un)
SERVICE = build-non-interactive

ENV_TEXT = "$\
SERVICE=${SERVICE}\n$\
LOCAL_CODE_DIR=../..\n$\
LOCAL_DATA_DIR=../../data\n$\
LOCAL_LOGS_DIR=../../logs\n$\
GID=${GID}\n$\
UID=${UID}\n$\
GRP=${GRP}\n$\
USR=${USR}\n$\
PASSWD=${USR}\n$\
LAB_NAME=${USR}\n$\
WANDB_API_KEY=\n$\
"
# PASSWD is only there to avoid running password-less sudo commands accidentally.

ENV_FILE = .env
-include ${ENV_FILE}

_COMPOSE_PROJECT = "${PROJECT_NAME}-${SERVICE}-${USR}"
COMPOSE_PROJECT = $(shell echo ${_COMPOSE_PROJECT} | tr "[:upper:]" "[:lower:]")

env:  # Creates the `.env` file if it does not exist.
	@test -f ${ENV_FILE} || printf ${ENV_TEXT} >> ${ENV_FILE}

check:  # Checks if the `.env` file exists.
	@if [ ! -f "${ENV_FILE}" ]; then \
		printf "File \`${ENV_FILE}\` does not exist. " && \
		printf "Run \`make env\` to create \`${ENV_FILE}\`.\n" && \
		exit 1; \
	fi

build: check # Build the image without creating a new container.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${PROJECT} build ${SERVICE}
up: check  # Start service. Creates a new container from the image.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${PROJECT} up -d ${SERVICE}
run: check # Used for debugging cases where the service will not start.
	docker compose -p ${PROJECT} run --rm ${SERVICE} ${COMMAND}