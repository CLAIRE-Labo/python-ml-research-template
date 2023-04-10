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

# `CONDA_MANAGER` may be either `mamba` or `conda`.
ARG CONDA_MANAGER

# Clean out package directories and `__pycache__` files to save space.
RUN --mount=type=bind,from=get-conda,source=/tmp/conda,target=/tmp/conda \
    /bin/bash /tmp/conda/miniconda.sh -b -p /opt/conda && \
    /opt/conda/bin/${CONDA_MANAGER} clean -ya --force-pkgs-dirs && \
    find /opt/conda -name '__pycache__' | xargs rm -rf

########################################################################
# Install apt packages.
# This layer can be used later to build other software.
# For example, it is used to build the python environment.

FROM ${BASE_IMAGE} AS train-apt-base

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=UTF-8
ENV NVIDIA_VISIBLE_DEVICES=all
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

# Configuration for ssh server. (Delete this if not needed.)
ENV NOTVISIBLE="in users profile"
RUN mkdir /var/run/sshd && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

########################################################################
# Install the conda environment.

FROM train-apt-base AS conda-env

ARG CONDA_MANAGER
ARG PATH=/opt/conda/bin:${PATH}
ARG PYTHONDONTWRITEBYTECODE=1
ARG PYTHONUNBUFFERED=1
ARG PIP_CACHE_DIR=/root/.cache/pip
ARG CONDA_PKGS_DIRS=/opt/conda/pkgs
ARG CONDA_ENV_FILE=/tmp/dependencies/environment.yml

COPY --link dependencies/environment.yml ${CONDA_ENV_FILE}
RUN --mount=type=bind,from=install-conda,source=/opt/conda,target=/opt/conda \
    --mount=type=cache,target=${PIP_CACHE_DIR},sharing=locked \
    --mount=type=cache,target=${CONDA_PKGS_DIRS},sharing=locked \
    /opt/conda/bin/${CONDA_MANAGER} env create --file ${CONDA_ENV_FILE}

# Cleaning must be in a separate `RUN` command to preserve the Docker cache.
RUN /opt/conda/bin/${CONDA_MANAGER} clean -fya && \
    find /opt/conda/envs/${PROJECT_NAME} -name '__pycache__' | xargs rm -rf

########################################################################
# Setting up a user.

FROM train-apt-base AS train-base

ARG GID
ARG UID
ARG GRP
ARG USR
ARG PASSWD
ENV PASSWD=${PASSWD}
# Persisting the user password for later use.

RUN groupadd -f -g ${GID} ${GRP} && \
    useradd --shell /bin/zsh --create-home -u ${UID} -g ${GRP} -p ${PASSWD} ${USR} && \
    usermod -aG sudo ${USR}

# Get conda with the directory ownership given to the user.
# This is to be able to install more packages in interactive mode.
COPY --link --from=conda-env --chown=${UID}:${GID} /opt/conda /opt/conda
RUN echo /opt/conda/lib >> /etc/ld.so.conf.d/conda.conf && ldconfig

# Create a directory for the project.
ARG PROJECT_ROOT
RUN mkdir ${PROJECT_ROOT} && chown ${USR}:${GRP} ${PROJECT_ROOT}

USER ${USR}
ARG HOME=/home/${USR}

# Zsh configuration.
## Setting the prompt to `pure`.
ARG PURE_PATH=${HOME}/.zsh/pure
COPY --link --from=get-pure --chown=${UID}:${GID} /opt/zsh/pure ${PURE_PATH}
RUN {   echo "fpath+=${PURE_PATH}"; \
        echo "autoload -Uz promptinit; promptinit"; \
        echo "prompt pure"; \
    } >> ${HOME}/.zshrc \

## Add syntax highlighting. This must be activated after auto-suggestions.
ARG ZSHS_PATH=${HOME}/.zsh/zsh-syntax-highlighting
COPY --link --from=stash --chown=${UID}:${GID} \
    /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
RUN echo "source ${ZSHS_PATH}/zsh-syntax-highlighting.zsh" >> ${HOME}/.zshrc

## Add custom aliases and settings.
RUN {   echo "alias ll='ls -lh'"; \
        echo "alias wns='watch nvidia-smi'"; \
        echo "alias hist='history 1'"; \
    } >> ${HOME}/.zshrc

# Initialize conda.
ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
ARG CONDA_MANAGER
RUN /bin/zsh -c "/opt/conda/bin/${CONDA_MANAGER} init zsh" &&\
    echo "${CONDA_MANAGER} activate ${PROJECT_NAME}" >> ${HOME}/.zshrc

########################################################################
# Final layer.

FROM train-base AS train

# If using your own .zshrc, mount it to ${HOME}/.local_zshrc and uncomment the following line.
# RUN echo "source ${HOME}/.local_zshrc" >> ${HOME}/.zshrc

# The following is for EPFL specific configuration.
ENV EPFL_CONFIG_DIR=/opt/EPFL_config
COPY --link EPFL_config $EPFL_CONFIG_DIR

ARG PROJECT_ROOT
ARG CODE_DIR
ARG DATA_DIR
ARG LOGS_DIR
ENV PROJECT_ROOT=${PROJECT_ROOT}
ENV CODE_DIR=${CODE_DIR}
ENV DATA_DIR=${DATA_DIR}
ENV LOGS_DIR=${LOGS_DIR}

WORKDIR ${PROJECT_ROOT}
ENTRYPOINT ["/bin/zsh", "-c"]
CMD ["sleep infinity"]
