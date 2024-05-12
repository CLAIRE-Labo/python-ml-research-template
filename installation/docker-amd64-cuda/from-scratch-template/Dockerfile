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
# Download Z-Shell enhancements.

FROM ${GIT_IMAGE} AS get-pure

ARG PURE_URL=https://github.com/sindresorhus/pure.git
ARG ZSHA_URL=https://github.com/zsh-users/zsh-autosuggestions.git
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

FROM ${BASE_IMAGE} AS build-apt-packages

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DEPENDENCIES_FILE=/tmp/dependencies/apt-build.txt
COPY --link dependencies/apt-build.txt ${BUILD_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-build.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${BUILD_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Install the conda environment.
## This stage can be reused to build Python packages.

FROM build-apt-packages AS build-conda-env

ARG PROJECT_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_CACHE_DIR=/root/.cache/pip
ARG CONDA_INSTALL_PATH
ENV CONDA_INSTALL_PATH=${CONDA_INSTALL_PATH}
ENV CONDA_CACHE_PKGS_DIRS=${CONDA_INSTALL_PATH}/pkgs
ARG CONDA_ENV_FILE=/tmp/dependencies/environment.yml
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}

COPY --link --from=install-conda ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}
COPY --link dependencies/environment.yml ${CONDA_ENV_FILE}
RUN --mount=type=cache,target=${PIP_CACHE_DIR},sharing=private \
    --mount=type=cache,target=${CONDA_CACHE_PKGS_DIRS},sharing=private \
    mamba env create --file ${CONDA_ENV_FILE}

# Record the dependency file after conda install which may be useful.
RUN mamba env export -n ${PROJECT_NAME} > ${CONDA_INSTALL_PATH}/environment-raw-after-env-create.yml

# Cleaning must be in a separate `RUN` command to preserve the Docker cache.
RUN mamba clean -fya && \
    find ${CONDA_INSTALL_PATH}/envs/${PROJECT_NAME} -name '__pycache__' | xargs rm -rf

# Enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
RUN echo 'int mkl_serv_intel_cpu_true() {return 1;}' > ${CONDA_INSTALL_PATH}/fakeintel.c && \
    gcc -shared -fPIC -o ${CONDA_INSTALL_PATH}/libfakeintel.so ${CONDA_INSTALL_PATH}/fakeintel.c

########################################################################
# Here you can install other software starting from build-apt-packages,
# then copy the installation artifacts to runtime-deps. (As done with the conda env).
# Think multi-stage and cache-efficient.

# You can also custom build and install pip packages starting from the build-conda-env stage.
# Just make sure to prefix your pip commands with `mamba run -n ${PROJECT_NAME} pip install ...`
# To have to package installed in the same location as the conda env of the project.

########################################################################
# 2. Stages for setting up the runtime environment.
########################################################################

########################################################################
# Install apt runtime packages.
# This layer is the base for the image that will run unattended jobs.
# Observe that build-apt-packages is not used anymore and will not be present in the final image.

FROM ${BASE_IMAGE} AS runtime-apt-pkgs

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNTIME_DEPENDENCIES_FILE=/tmp/dependencies/apt-runtime.txt
COPY --link dependencies/apt-runtime.txt ${RUNTIME_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-runtime.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${RUNTIME_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Copy over the conda env and other build artifacts and software.
# You can use this stage to test the conda env and other build artifacts.

FROM runtime-apt-pkgs AS runtime-deps

# A directory to record all the dependency files used at multiple stages.
# This is useful for a later inspection or debugging.
ENV DEPENDENCIES_DIR=/opt/template-dependencies
RUN mkdir -m 777 ${DEPENDENCIES_DIR}
COPY dependencies/apt-build.txt ${DEPENDENCIES_DIR}/apt-build.txt
COPY dependencies/apt-runtime.txt ${DEPENDENCIES_DIR}/apt-runtime.txt
COPY dependencies/environment.yml ${DEPENDENCIES_DIR}/environment.yml

# Copy the conda env.
# Make it writeable by anyone so that it can be updated by the user created in the last layer.
ARG CONDA_INSTALL_PATH
ARG PROJECT_NAME
ENV CONDA_INSTALL_PATH=${CONDA_INSTALL_PATH}
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}
COPY --link --from=build-conda-env --chmod=777 ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}
COPY --link --from=build-conda-env ${CONDA_INSTALL_PATH}/environment-raw-after-env-create.yml \
    ${DEPENDENCIES_DIR}/environment-raw-after-env-create.yml

# Optional optimizations.
# Enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
ENV LD_PRELOAD=${CONDA_INSTALL_PATH}/libfakeintel.so:${LD_PRELOAD}

########################################################################
# This stage is the final user-agnostic (generic) stage.
# It contains all the dependencies of the environment and the setup scripts.
# It will be extended to do the final user configuration.
# This layer can be distributed so that subsequent users
# don't have to build the whole environment from scratch.
# Only their user configuration will be added on top of this layer.
# This would improve the reproducibility of the project.

FROM runtime-deps AS runtime-generic

ARG PROJECT_NAME
ARG PACKAGE_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV HYDRA_FULL_ERROR=1

# A final record of the depedenencies from mamba.
RUN mamba env export -n ${PROJECT_NAME} > ${DEPENDENCIES_DIR}/environment-raw-final.yml

# Shell configuration.
ENV ZSH_ENHANCE_DIR=/etc/zsh/enhance
ENV GLOBAL_ZSHRC=/etc/zsh/zshrc

ARG PURE_PATH=${ZSH_ENHANCE_DIR}/pure
ARG ZSHA_PATH=${ZSH_ENHANCE_DIR}/zsh-autosuggestions
ARG ZSHS_PATH=${ZSH_ENHANCE_DIR}/zsh-syntax-highlighting
COPY --link --from=get-pure /opt/zsh/pure ${PURE_PATH}
COPY --link --from=get-pure /opt/zsh/zsh-autosuggestions ${ZSHA_PATH}
COPY --link --from=get-pure /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
# Utilities for interactive shells.
RUN {   echo "fpath+=${PURE_PATH}"; \
        echo "autoload -Uz promptinit; promptinit"; \
        echo "prompt pure"; \
        echo "source ${ZSHA_PATH}/zsh-autosuggestions.zsh"; \
        echo "source ${ZSHS_PATH}/zsh-syntax-highlighting.zsh"; \
        echo "alias ls='ls --color=auto'"; \
        echo "alias ll='ls -lh'"; \
        echo "alias wns='watch nvidia-smi'"; \
        echo "alias hist='history 1'"; \
        echo "alias update-env-file='source \${PROJECT_ROOT_AT}/installation/docker-amd64-cuda/dependencies/update-env-file.sh'"; \
        echo "if [ -n \"\${PROJECT_ROOT_AT}\" ]; then cd \${PROJECT_ROOT_AT}; fi"; \
    } >> ${GLOBAL_ZSHRC}

# Initialize conda for interactive shells, the entrypoint is run as an interactive shell.
## Write it in /root/.zshrc (which is empty before) and copy to the global zshrc.
RUN /bin/zsh -i -c "mamba init zsh" && \
    cat /root/.zshrc >> ${GLOBAL_ZSHRC} && \
    rm /root/.zshrc && \
    echo "mamba activate ${PROJECT_NAME}" >> ${GLOBAL_ZSHRC}

# A place to put the project if needed.
RUN mkdir -m 777 /project

# Entrypoints.
# The entrypoint is run in an interactive shell so that the conda environment is activated before.
# Don't overwrite the entrypoint, it is installing the project
# and testing that you correctly mounted the project code.
# It also performs some other important setup depending on the deployment platform.
ENV ENTRYPOINTS_ROOT=/opt/template-entrypoints
COPY --link --chmod=777 entrypoints ${ENTRYPOINTS_ROOT}
ENTRYPOINT ["/bin/zsh", "-i", "/opt/template-entrypoints/entrypoint.sh"]
CMD ["/bin/zsh"]

########################################################################
# 3. Stages for setting up the user and the development environment.
# Continued in the Dockerfile-user file.
########################################################################

########################################################################
# Generic layer for development

FROM runtime-generic AS development-generic

# Install development packages.

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_DEPENDENCIES_FILE=/tmp/dependencies/apt-dev.txt
COPY --link dependencies/apt-dev.txt ${DEV_DEPENDENCIES_FILE}

# sed is only used as a hack to remove comments from the file apt-dev.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${DEV_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY dependencies/apt-dev.txt ${DEPENDENCIES_DIR}/apt-dev.txt
