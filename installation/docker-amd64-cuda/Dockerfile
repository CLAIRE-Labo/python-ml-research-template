# syntax = docker/dockerfile:1

# BASE_IMAGE is the image that will be extended by this Dockerfile.
# It is assumed to a well configured Python installation.
# The reminaing packages will be installed with pip.

ARG BASE_IMAGE
ARG GIT_IMAGE

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
# Install apt packages.

FROM ${BASE_IMAGE} AS runtime-apt-pkgs

# A directory to record all the dependency files used at multiple stages.
# This is useful for a later inspection or debugging.
ENV DEPENDENCIES_DIR=/opt/template-dependencies
RUN mkdir ${DEPENDENCIES_DIR}
COPY apt.txt ${DEPENDENCIES_DIR}/apt.txt

# Enable caching for `apt` packages in Docker.
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > \
    /etc/apt/apt.conf.d/keep-cache

ARG DEBIAN_FRONTEND=noninteractive
# sed is only used as a hack to remove comments from the file apt.txt.
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt update && \
    sed -e 's/#.*//g' -e 's/\r//g' ${DEPENDENCIES_DIR}/apt.txt | \
    xargs -t apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Podman: Comment the above and use this instead with podman as it doesn't support sharing mount modes.
#RUN apt update && \
#    sed -e 's/#.*//g' -e 's/\r//g' ${DEPENDENCIES_DIR}/apt.txt | \
#    xargs -t apt-get install -y --no-install-recommends && \
#    rm -rf /var/lib/apt/lists/*

########################################################################
# Install dependencies.

FROM runtime-apt-pkgs AS runtime-deps

# Install pip packages.
ENV PIP_CACHE_DIR=/root/.cache/pip
RUN pip freeze > ${DEPENDENCIES_DIR}/requirements-raw-before-pip-install.txt
COPY requirements.txt ${DEPENDENCIES_DIR}/requirements.txt
RUN --mount=type=cache,target=${PIP_CACHE_DIR},sharing=private \
    pip install -r ${DEPENDENCIES_DIR}/requirements.txt
# Podman: Comment the above and use this instead with podman as it doesn't support sharing mount modes.
#RUN pip install -r ${DEPENDENCIES_DIR}/requirements.txt
RUN pip freeze > ${DEPENDENCIES_DIR}/requirements-raw-after-pip-install.txt

# Optional optimizations.
# Hack to enable Intel MKL optimizations on AMD CPUs.
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
ARG FAKEINTEL_PATH=/opt/fakeintel/libfakeintel.so
ENV FAKEINTEL_PATH=${FAKEINTEL_PATH}
# https://danieldk.eu/Posts/2020-08-31-MKL-Zen.html
# Build.
RUN echo 'int mkl_serv_intel_cpu_true() {return 1;}' > /tmp/fakeintel.c && \
    mkdir -p /opt/fakeintel && \
    gcc -shared -fPIC -o ${FAKEINTEL_PATH} /tmp/fakeintel.c
# Enable.
ENV LD_PRELOAD=${FAKEINTEL_PATH}:${LD_PRELOAD}

########################################################################
# Here you can install other software

########################################################################
# This stage is the final user-agnostic (generic) stage.
# This layer can be distributed so that subsequent users

FROM runtime-deps AS runtime-generic

ARG PROJECT_NAME
ARG PACKAGE_NAME
ENV PROJECT_NAME=${PROJECT_NAME}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV HYDRA_FULL_ERROR=1

# A final record of the dependencies from pip freeze.
RUN pip freeze > ${DEPENDENCIES_DIR}/requirements-raw-final.txt

# Shell configuration.
ENV ZSH_ENHANCE_DIR=/etc/zsh/enhance
ARG PURE_PATH=${ZSH_ENHANCE_DIR}/pure
ARG ZSHA_PATH=${ZSH_ENHANCE_DIR}/zsh-autosuggestions
ARG ZSHS_PATH=${ZSH_ENHANCE_DIR}/zsh-syntax-highlighting
COPY --from=get-pure /opt/zsh/pure ${PURE_PATH}
COPY --from=get-pure /opt/zsh/zsh-autosuggestions ${ZSHA_PATH}
COPY --from=get-pure /opt/zsh/zsh-syntax-highlighting ${ZSHS_PATH}
RUN {   echo "fpath+=${PURE_PATH}"; \
        echo "autoload -Uz promptinit; promptinit"; \
        echo "prompt pure"; \
        echo "source ${ZSHA_PATH}/zsh-autosuggestions.zsh"; \
        echo "source ${ZSHS_PATH}/zsh-syntax-highlighting.zsh"; \
        echo "alias ls='ls --color=auto'"; \
        echo "alias ll='ls -lh'"; \
        echo "alias update-env-file='source \${PROJECT_ROOT_AT}/installation/docker-amd64-cuda/update-env-file.sh'"; \
    } >> /etc/zsh/zshrc


# Entrypoints.
# Don't overwrite the entrypoint, it is installing the project
# and testing that you correctly mounted the project code.
# It also performs some other important setup depending on the deployment platform.
ARG BASE_ENTRYPOINT
ARG BASE_ENTRYPOINT_EXECS
ENV BASE_ENTRYPOINT=${BASE_ENTRYPOINT}
ENV BASE_ENTRYPOINT_EXECS=${BASE_ENTRYPOINT_EXECS}
ENV ENTRYPOINTS_ROOT=/opt/template-entrypoints
COPY entrypoints ${ENTRYPOINTS_ROOT}
ENTRYPOINT ["/opt/template-entrypoints/pre-entrypoint.sh"]
CMD ["/bin/zsh"]
