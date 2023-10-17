# syntax = docker/dockerfile:1

# CURL_IMAGE is used to download from the internet in independent layers.
# GIT_IMAGE is used to clone git repositories in independent layers.
# BASE_IMAGE is the base image for the project, likely the Ubuntu image.

ARG CURL_IMAGE
ARG GIT_IMAGE
ARG BASE_IMAGE

########################################################################
# 1. Stages for downloading, installing, and building things.
########################################################################

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
# Install apt build packages.
## This stage can be reused to build other software.
## For example, it is used to build the conda environment in the conda-env stage.

FROM ${BASE_IMAGE} AS apt-build-base

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG BUILD_DEPENDENCIES_FILE=/tmp/dependencies/apt-build.txt
COPY --link dependencies/apt-build.txt ${BUILD_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-build.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${BUILD_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Install the conda environment.

FROM apt-build-base AS conda-env

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

# Enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
RUN echo 'int mkl_serv_intel_cpu_true() {return 1;}' > ${CONDA_INSTALL_PATH}/fakeintel.c && \
    gcc -shared -fPIC -o ${CONDA_INSTALL_PATH}/libfakeintel.so ${CONDA_INSTALL_PATH}/fakeintel.c

########################################################################
# Here you can install other software starting from apt-build-base,
# then copy the installation artifacts to runtime-base. (As done with the conda env).
# Think multi-stage and cache-efficient.

# You can also custom build and install pip packages starting from the conda-env stage.
# Just make sure to prefix your pip commands with `mamba run -n ${PROJECT_NAME} pip install ...`
# To have to package installed in the same location as the conda env of the project.

########################################################################
# 2. Stages for setting up the runtime environment.
########################################################################

########################################################################
# Install apt runtime packages.
# This layer is the base for the image that you will run.
# Observe that apt-build-base is not used anymore and will not be present in the final image.

FROM ${BASE_IMAGE} AS apt-runtime-base

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=UTF-8
ARG DEBIAN_FRONTEND=noninteractive
ENV HYDRA_FULL_ERROR=1

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG RUNTIME_DEPENDENCIES_FILE=/tmp/dependencies/apt-runtime.txt
COPY --link dependencies/apt-runtime.txt ${RUNTIME_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-runtime.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${RUNTIME_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Copy over the conda env and other build artifacts and software.
# You can use this stage to debug the conda env and other build artifacts.

FROM apt-runtime-base AS runtime-base

# Copy the conda env
# The ownership of the conda directory will later be changed to the user to install packages interactively.
ARG CONDA_INSTALL_PATH
ENV CONDA_INSTALL_PATH=${CONDA_INSTALL_PATH}
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}
COPY --link --from=conda-env ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}

# Optional optimizations.
# Enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
ENV LD_PRELOAD=${CONDA_INSTALL_PATH}/libfakeintel.so:${LD_PRELOAD}

########################################################################
# This stage is the final user agnostic stage.
# It contains all the dependencies of the environment and the setup scripts.
# It will be extended to do the final user configuration.
# This layer can be distributed so that subsequent users
# don't have to build the whole environment from scratch.
# Only their user configuration will be added on top of this layer.
# This would improve the reproducibility of the project.

FROM runtime-base AS runtime-project-base-no-user

ARG PROJECT_NAME
ARG PACKAGE_NAME
ARG PROJECT_ROOT
ARG PROJECT_DIR
ARG DATA_DIR
ARG OUTPUTS_DIR
ARG WWANDB_DIR
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV PROJECT_DIR=${PROJECT_DIR}
ENV PROJECT_ROOT=${PROJECT_ROOT}
ENV DATA_DIR=${DATA_DIR}
ENV OUTPUTS_DIR=${OUTPUTS_DIR}
ENV WWANDB_DIR=${WWANDB_DIR}

# {PROJECT, DATA, OUTPUTS, WWANDB}_DIR are where you will mount your code data and outputs.
# The template sets a base structure for the I/O directories of the project.
#
# PROJECT_ROOT
# ├── PROJECT_DIR
# ├── DATA_DIR
# ├── OUTPUTS_DIR
# └── WWANDB_DIR

# Create a directory for the project root.
RUN mkdir -p ${PROJECT_ROOT}

# Create a directory for the startup scripts.
ENV ENTRYPOINTS_ROOT=/opt/entrypoints
RUN mkdir -p ${ENTRYPOINTS_ROOT}

# The entrypoint is run in an interactive shell so that the conda environment is activated before.
# Don't overwrite the entrypoint, it is installing the project
# and testing that you correctly mounted the project code and data and output directories.
# It also performs some other important setup depending on the deployment platform.
COPY --link entrypoint.sh ${ENTRYPOINTS_ROOT}/entrypoint.sh
ENTRYPOINT ["/bin/zsh", "-i", "/opt/entrypoints/entrypoint.sh"]
CMD ["/bin/zsh"]
# You call always attach shells to the running container after it started at the entrypoint.

# The following is for EPFL-specific configurations and setup.
ENV EPFL_RUNAI_SETUP_DIR=${ENTRYPOINTS_ROOT}/EPFL-runai-setup
COPY --link EPFL-runai-setup ${EPFL_RUNAI_SETUP_DIR}

# PROJECT_ROOT is where you want all your scripts to run from.
WORKDIR ${PROJECT_ROOT}

########################################################################
# 3. Stages for setting up the user and the development environment.
########################################################################

########################################################################
# Final runtime layer for the user.

FROM runtime-project-base-no-user AS runtime

ARG PROJECT_NAME
ARG PROJECT_DIR
ARG GRPID
ARG USRID
ARG GRP
ARG USR
ARG PASSWD
ENV PASSWD=${PASSWD}

RUN groupadd -f -g ${GRPID} ${GRP} && \
    useradd --shell /bin/zsh --create-home -u ${USRID} -g ${GRP} -p  $(openssl passwd -1 ${PASSWD}) ${USR} && \
    usermod -aG sudo ${USR}

# Change ownership of all relevant directories to the user.
RUN chown -R ${USR}:${GRP} ${PROJECT_ROOT} && \
    chown -R ${USR}:${GRP} ${ENTRYPOINTS_ROOT} && \
    chown -R ${USR}:${GRP} ${CONDA_INSTALL_PATH}

# Use the user to do its shell configuration.
USER ${USR}

# Zsh configuration.
# Also useful for unattended runs when attaching a shell for audits.
ENV ZDOTDIR=/home/${USR}

ARG PURE_PATH=${ZDOTDIR}/.zsh/pure
ARG ZSHA_PATH=${ZDOTDIR}/.zsh/zsh-autosuggestions
ARG ZSHS_PATH=${ZDOTDIR}/.zsh/zsh-syntax-highlighting
COPY --link --from=get-pure --chown=${USRID}:${GRPID} /opt/zsh/pure ${PURE_PATH}
COPY --link --from=get-pure --chown=${USRID}:${GRPID} /opt/zsh/zsh-autosuggestions ${ZSHA_PATH}
COPY --link --from=get-pure --chown=${USRID}:${GRPID} /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
RUN {   echo "fpath+=${PURE_PATH}"; \
        echo "autoload -Uz promptinit; promptinit"; \
        echo "prompt pure"; \
        echo "source ${ZSHA_PATH}/zsh-autosuggestions.zsh"; \
        echo "source ${ZSHS_PATH}/zsh-syntax-highlighting.zsh"; \
        echo "alias ls='ls --color=auto'"; \
        echo "alias ll='ls -lh'"; \
        echo "alias wns='watch nvidia-smi'"; \
        echo "alias hist='history 1'"; \
        echo "alias update_env_file='source \${PROJECT_DIR}/installation/docker-amd64/dependencies/update_env_file.sh'"; \
    } >> ${ZDOTDIR}/.zshrc

# Initialize conda for interactive shells.
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}
ENV ZDOTDIR=/home/${USR}
RUN /bin/zsh -i -c "mamba init zsh" && \
    {   echo "mamba activate ${PROJECT_NAME}"; \
        echo "alias conda=mamba # For those who still think it's conda :)"; \
    } >> ${ZDOTDIR}/.zshrc
########################################################################
# Final development layer for the user.

FROM runtime AS development

# Temporarily switch to root.
USER root

# Install development packages.

## Install apt development packages.
ARG DEV_DEPENDENCIES_FILE=/tmp/dependencies/apt-dev.txt
COPY --link dependencies/apt-dev.txt ${DEV_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-dev.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${DEV_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Back to the user.
ARG USR
USER ${USR}
