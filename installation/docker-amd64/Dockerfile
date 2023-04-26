# syntax = docker/dockerfile:1

# CURL_IMAGE is used to download from the internet in independent layers.
# GIT_IMAGE is used to clone git repositories in independent layers.
# BASE_IMAGE is the base image for the project.

ARG CURL_IMAGE
ARG GIT_IMAGE
ARG BASE_IMAGE

########################################################################
# Download Z-Shell related libraries.

FROM ${GIT_IMAGE} AS get-pure

ARG PURE_URL=https://github.com/sindresorhus/pure.git
ARG ZSHA_URL=https://github.com/zsh-users/zsh-autosuggestions
ARG ZSHS_URL=https://github.com/zsh-users/zsh-syntax-highlighting.git

RUN git clone --depth 1 ${PURE_URL} /opt/zsh/pure
RUN git clone --depth 1 ${ZSHA_URL} /opt/zsh/zsh-autosuggestions
RUN git clone --depth 1 ${ZSHS_URL} /opt/zsh/zsh-syntax-highlighting

########################################################################
# Download conda.

FROM ${CURL_IMAGE} AS get-conda
ARG CONDA_URL
RUN mkdir /tmp/conda && \
    curl -fvL -o /tmp/conda/miniconda.sh ${CONDA_URL}

########################################################################
# Install conda.

FROM ${BASE_IMAGE} AS install-conda

ARG CONDA_INSTALL_PATH
RUN --mount=type=bind,from=get-conda,source=/tmp/conda,target=/tmp/conda \
    /bin/bash /tmp/conda/miniconda.sh -b -p ${CONDA_INSTALL_PATH}

########################################################################
# Install apt packages.
# This layer can be used later to build other software.
# For example, it is used to build the python environment.

FROM ${BASE_IMAGE} AS train-apt-base

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=UTF-8
ARG DEBIAN_FRONTEND=noninteractive

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG DEPENDENCIES_FILE=/tmp/dependencies/apt.txt
COPY --link dependencies/apt.txt ${DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Install the conda environment.

FROM train-apt-base AS conda-env

ARG PROJECT_NAME
ARG PYTHONDONTWRITEBYTECODE=1
ARG PYTHONUNBUFFERED=1
ARG PIP_CACHE_DIR=/root/.cache/pip
ARG CONDA_INSTALL_PATH
ARG CONDA_PKGS_DIRS=${CONDA_INSTALL_PATH}/pkgs
ARG CONDA_ENV_FILE=/tmp/dependencies/environment.yml
ARG PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}

COPY --link --from=install-conda ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}
COPY --link dependencies/environment.yml ${CONDA_ENV_FILE}
RUN --mount=type=cache,target=${PIP_CACHE_DIR},sharing=locked \
    --mount=type=cache,target=${CONDA_PKGS_DIRS},sharing=locked \
    mamba env create --file ${CONDA_ENV_FILE}

# Cleaning must be in a separate `RUN` command to preserve the Docker cache.
RUN mamba clean -fya && \
    find ${CONDA_INSTALL_PATH}/envs/${PROJECT_NAME} -name '__pycache__' | xargs rm -rf

########################################################################
# Here you can install other software starting from train-apt-base,
# then copy the installation artifacts to train-base. (As done with the conda env).
# Think multi-stage and cache-efficient.

########################################################################
# Setting up a user.

FROM train-apt-base AS train-base

ARG PROJECT_NAME
ARG GID
ARG UID
ARG GRP
ARG USR
ARG PASSWD
ENV PASSWD=${PASSWD}

RUN groupadd -f -g ${GID} ${GRP} && \
    useradd --shell /bin/zsh --create-home -u ${UID} -g ${GRP} -p  $(openssl passwd -1 ${PASSWD}) ${USR} && \
    usermod -aG sudo ${USR}
# Create a directory for the project and a directory for startup scripts.
ARG PROJECT_ROOT
ENV PROJECT_ROOT=${PROJECT_ROOT}
ENV ENTRYPOINTS_ROOT=/opt/entrypoints
RUN mkdir -p ${PROJECT_ROOT} && chown ${USR}:${GRP} ${PROJECT_ROOT} && \
    mkdir -p ${ENTRYPOINTS_ROOT} && chown ${USR}:${GRP} ${ENTRYPOINTS_ROOT}

# Get conda with the directory ownership given to the user.
# This is to be able to install more packages in interactive mode.
ARG CONDA_INSTALL_PATH
ENV CONDA_INSTALL_PATH=${CONDA_INSTALL_PATH}
COPY --link --from=conda-env --chown=${UID}:${GID} ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}

# Set the user.
USER ${USR}

# Initialize conda for interactive shells.
ARG PROJECT_NAME
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}
ENV ZDOTDIR=/home/${USR}
RUN /bin/zsh -i -c "mamba init zsh" && \
    {   echo "mamba activate ${PROJECT_NAME}"; \
        echo "alias conda=mamba # For those who still think it's conda :)"; \
    } >> ${ZDOTDIR}/.zshrc

# Zsh configuration.
ARG PURE_PATH=${ZDOTDIR}/.zsh/pure
ARG ZSHA_PATH=${ZDOTDIR}/.zsh/zsh-autosuggestions
ARG ZSHS_PATH=${ZDOTDIR}/.zsh/zsh-syntax-highlighting
COPY --link --from=get-pure --chown=${UID}:${GID} /opt/zsh/pure ${PURE_PATH}
COPY --link --from=get-pure --chown=${UID}:${GID} /opt/zsh/zsh-autosuggestions ${ZSHA_PATH}
COPY --link --from=get-pure --chown=${UID}:${GID} /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
RUN {   echo "fpath+=${PURE_PATH}"; \
        echo "autoload -Uz promptinit; promptinit"; \
        echo "prompt pure"; \
        echo "source ${ZSHA_PATH}/zsh-autosuggestions.zsh"; \
        echo "source ${ZSHS_PATH}/zsh-syntax-highlighting.zsh"; \
        echo "alias ls='ls --color=auto'"; \
        echo "alias ll='ls -lh'"; \
        echo "alias wns='watch nvidia-smi'"; \
        echo "alias hist='history 1'"; \
        echo "alias update_env_file='source installation/docker-amd64/dependencies/update_env_file.sh'"; \
    } >> ${ZDOTDIR}/.zshrc

########################################################################
# Final layer.

FROM train-base AS train

ARG PROJECT_NAME
ARG PACKAGE_NAME
ARG PROJECT_DIR
ARG DATA_DIR
ARG OUTPUTS_DIR
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV PROJECT_DIR=${PROJECT_DIR}
ENV DATA_DIR=${DATA_DIR}
ENV OUTPUTS_DIR=${OUTPUTS_DIR}

WORKDIR ${PROJECT_ROOT}

# Entrypoint is an interactive shell to activate the conda environment.
# Don't overwrite the entrypoint it is installing the project
# and testing that you correctly mounted your volume.
# It only needs to run once, so you can attach shells later without running it.
COPY --link entrypoint.sh ${ENTRYPOINTS_ROOT}/entrypoint.sh
ENTRYPOINT ["/bin/zsh", "-i", "/opt/entrypoints/entrypoint.sh"]
CMD ["/bin/zsh"]

# The following is for EPFL specific configuration.
ENV EPFL_RUNAI_SETUP_DIR=${ENTRYPOINTS_ROOT}/EPFL-runai-setup
COPY --link EPFL-runai-setup ${EPFL_RUNAI_SETUP_DIR}
