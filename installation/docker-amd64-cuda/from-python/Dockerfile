# syntax = docker/dockerfile:1

# BASE_IMAGE is the image that will be extended by this Dockerfile.
# It is assumed to a well configured Python installation.
# The reminaing packages will be installed with pip.

ARG BASE_IMAGE
ARG GIT_IMAGE

########################################################################
# 1. Stages for downloading, installing, and building things.
########################################################################

########################################################################
# Download Z-Shell enhancements.

FROM ${GIT_IMAGE} AS get-pure

ARG PURE_URL=https://github.com/sindresorhus/pure.git
ARG ZSHA_URL=https://github.com/zsh-users/zsh-autosuggestions
ARG ZSHS_URL=https://github.com/zsh-users/zsh-syntax-highlighting.git

RUN git clone --depth 1 ${PURE_URL} /opt/zsh/pure
RUN git clone --depth 1 ${ZSHA_URL} /opt/zsh/zsh-autosuggestions
RUN git clone --depth 1 ${ZSHS_URL} /opt/zsh/zsh-syntax-highlighting


########################################################################
# Install missing apt build packages.
## This stage can be reused to build other software.

FROM ${BASE_IMAGE} AS build-apt-packages

ARG DEBIAN_FRONTEND=noninteractive

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

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
# Enable Intel MKL optimizations on AMD CPUs.

FROM build-apt-packages AS build-fakeintel

# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
RUN echo 'int mkl_serv_intel_cpu_true() {return 1;}' > /tmp/fakeintel.c && \
    mkdir -p /opt/fakeintel && \
    gcc -shared -fPIC -o /opt/fakeintel/libfakeintel.so /tmp/fakeintel.c


########################################################################
# Here you can install other software starting from build-apt-packages,
# then copy the installation artifacts to runtime-base.
# Think multi-stage and cache-efficient.
# The MKL hack for AMD can be seen as an example.


########################################################################
# 2. Stages for setting up the runtime environment.
########################################################################

########################################################################
# Install apt runtime packages.
# This layer is the base for the image that will run unattended jobs.
# Observe that build-apt-packages is not used anymore and will not be present in the final image.

FROM ${BASE_IMAGE} AS runtime-apt-pkgs

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNTIME_DEPENDENCIES_FILE=/tmp/dependencies/apt-runtime.txt
COPY --link dependencies/apt-runtime.txt ${RUNTIME_DEPENDENCIES_FILE}

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

# sed is only used as a hack to remove comments from the file apt-runtime.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${RUNTIME_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

########################################################################
# Copy build artifacts and software.
# You can use this stage to test the python env and other build artifacts.

FROM runtime-apt-pkgs AS runtime-deps

# Install pip packages.
ARG PIP_REQS_FILE=/tmp/dependencies/requirements.txt
COPY --link dependencies/requirements.txt ${PIP_REQS_FILE}
RUN pip install -r ${PIP_REQS_FILE}

# Record all the dependency files in the image to know what was installed.
ARG DEPENDENCIES_DIR=/opt/template-dependencies
COPY --link --chmod=777 dependencies ${DEPENDENCIES_DIR}
RUN pip freeze > ${DEPENDENCIES_DIR}/requirements_after_build.txt

# Optional optimizations.
# Enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
ARG FAKEINTEL_PATH=/opt/fakeintel/libfakeintel.so
COPY --link --from=build-fakeintel --chmod=777 ${FAKEINTEL_PATH} ${FAKEINTEL_PATH}
ENV LD_PRELOAD=${FAKEINTEL_PATH}:${LD_PRELOAD}

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

# Shell configuration.
ENV ZSH_ENHANCE_DIR=/etc/zsh/enhance
ENV GLOBAL_ZSHRC=/etc/zsh/zshrc

ARG PURE_PATH=${ZSH_ENHANCE_DIR}/pure
ARG ZSHA_PATH=${ZSH_ENHANCE_DIR}/zsh-autosuggestions
ARG ZSHS_PATH=${ZSH_ENHANCE_DIR}/zsh-syntax-highlighting
COPY --link --from=get-pure --chmod=777 /opt/zsh/pure ${PURE_PATH}
COPY --link --from=get-pure --chown=777 /opt/zsh/zsh-autosuggestions ${ZSHA_PATH}
COPY --link --from=get-pure --chown=777 /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
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

# A place to put the project if needed.
RUN mkdir -m 777 /project

# Entrypoints.
# Don't overwrite the entrypoint, it is installing the project
# and testing that you correctly mounted the project code.
# It also performs some other important setup depending on the deployment platform.

ARG BASE_ENTRYPOINT
ENV BASE_ENTRYPOINT=${BASE_ENTRYPOINT}
ENV ENTRYPOINTS_ROOT=/opt/template-entrypoints
COPY --link --chmod=777 entrypoints ${ENTRYPOINTS_ROOT}
ENTRYPOINT ["/opt/template-entrypoints/pre-entrypoint.sh" ]
CMD ["/bin/zsh"]

########################################################################
# 3. Stages for setting up the user and the development environment.
# Continued in the Dockerfile-user file.
########################################################################

########################################################################
# Generic layer for development

FROM runtime-generic AS development-generic

# Install development packages.

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_DEPENDENCIES_FILE=/tmp/dependencies/apt-dev.txt
COPY --link dependencies/apt-dev.txt ${DEV_DEPENDENCIES_FILE}

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

# sed is only used as a hack to remove comments from the file apt-dev.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${DEV_DEPENDENCIES_FILE} | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*
