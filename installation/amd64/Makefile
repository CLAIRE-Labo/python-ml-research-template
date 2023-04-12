define ENV_TEXT
# User-specific environment variables only.
SERVICE=build-non-interactive
LOCAL_CODE_DIR=../..
LOCAL_DATA_DIR=../../data
LOCAL_LOGS_DIR=../../logs
GID=$(shell id -g)
UID=$(shell id -u)
GRP=$(shell id -gn)
USR=$(shell id -un)
# PASSWD is not secret,
# it is only there to avoid running password-less sudo commands accidentally.
PASSWD=$(shell id -un)
LAB_NAME=$(shell id -un)
WANDB_API_KEY=0
endef
export ENV_TEXT

# All variables below are read from the `.env` file.
ENV_FILE = .env
-include ${ENV_FILE}

_COMPOSE_PROJECT = "<project-name>-${USR}"
COMPOSE_PROJECT = $(shell echo ${_COMPOSE_PROJECT} | tr "[:upper:]" "[:lower:]")

env:  # Creates the `.env` file if it does not exist.
	@test -f ${ENV_FILE} || printf "$$ENV_TEXT" >> ${ENV_FILE}

check:  # Checks if the `.env` file exists.
	@if [ ! -f "${ENV_FILE}" ]; then \
		printf "File \`${ENV_FILE}\` does not exist. " && \
		printf "Run \`make env\` to create \`${ENV_FILE}\`.\n" && \
		exit 1; \
	fi

build: check # Build the image without creating a new container.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${COMPOSE_PROJECT} build ${SERVICE}
up: check  # Start service. Creates a new container from the image.
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
	docker compose -p ${COMPOSE_PROJECT} up -d ${SERVICE}
exec:	# Enter interactive shell.
	DOCKER_BUILDKIT=1 \
	docker compose -p ${COMPOSE_PROJECT} exec ${SERVICE} /bin/zsh
run:	# Run a command in a new container.
	docker compose -p ${COMPOSE_PROJECT} run --rm ${SERVICE}
# Useful if the previous container must not be deleted.
start:	# Start a stopped service without recreating the container.
	docker compose -p ${COMPOSE_PROJECT} start ${SERVICE}
down:	# Shut down the service and delete containers, volumes, networks, etc.
	docker compose -p ${COMPOSE_PROJECT} down