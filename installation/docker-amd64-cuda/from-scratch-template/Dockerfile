# syntax = docker/dockerfile:1

# CURL_IMAGE is used to download from the internet in independent layers.
# GIT_IMAGE is used to clone git repositories in independent layers.
# BASE_IMAGE is the base image for the project, likely the Ubuntu image.
ARG CURL_IMAGE
ARG GIT_IMAGE
ARG BASE_IMAGE

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

########################################################################
# Install dependencies.

FROM runtime-apt-pkgs AS runtime-deps

ARG PROJECT_NAME
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_CACHE_DIR=/root/.cache/pip
ARG CONDA_INSTALL_PATH
ENV CONDA_INSTALL_PATH=${CONDA_INSTALL_PATH}
ENV CONDA_CACHE_PKGS_DIRS=${CONDA_INSTALL_PATH}/pkgs
ENV PATH=${CONDA_INSTALL_PATH}/condabin:${PATH}

COPY --link --from=install-conda ${CONDA_INSTALL_PATH} ${CONDA_INSTALL_PATH}
COPY environment.yml ${DEPENDENCIES_DIR}/environment.yml
RUN --mount=type=cache,target=${PIP_CACHE_DIR},sharing=private \
    --mount=type=cache,target=${CONDA_CACHE_PKGS_DIRS},sharing=private \
    mamba env create --file ${DEPENDENCIES_DIR}/environment.yml

# Record the dependency file after conda install which may be useful.
RUN mamba env export -n ${PROJECT_NAME} > ${DEPENDENCIES_DIR}/environment-mamba-after-env-create.yml

# Cleaning must be in a separate `RUN` command to preserve the Docker cache.
RUN mamba clean -fya && \
    find ${CONDA_INSTALL_PATH}/envs/${PROJECT_NAME} -name '__pycache__' | xargs rm -rf

# Make the conda env writeable by anyone so that it can be updated by a user.
RUN chmod -R 777 ${CONDA_INSTALL_PATH}

# Add conda env to path.
ENV PATH=${CONDA_INSTALL_PATH}/envs/${PROJECT_NAME}/bin:${PATH}

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
# You can build and install pip packages
# Just make sure to prefix your pip commands with `mamba run -n ${PROJECT_NAME} pip install ...`
# to have to package installed in the same location as the conda env of the project.

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
# This stage is the final user-agnostic (generic) stage.
# This layer can be distributed so that subsequent users

FROM runtime-deps AS runtime-generic

ARG PROJECT_NAME
ENV HYDRA_FULL_ERROR=1

# A final record of the depedenencies from mamba (to record the any extra custom installs)
RUN mamba env export -n ${PROJECT_NAME} > ${DEPENDENCIES_DIR}/environment-mamba-final.yml

# Initialize conda for login and interactive shells, for a better development experience.
# Although the environment is already in the PATH.
RUN mamba init --system bash
RUN { echo "mamba activate ${PROJECT_NAME}"; \
    } >> /etc/profile.d/conda.sh
RUN cat /etc/profile.d/conda.sh >> /etc/bash.bashrc
RUN cat /etc/profile.d/conda.sh >> /etc/zsh/zprofile
RUN cat /etc/profile.d/conda.sh >> /etc/zsh/zshrc

# Shell configuration.
ENV ZSH_ENHANCE_DIR=/etc/zsh/enhance
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
        echo "alias update-env-file='source \${PROJECT_ROOT_AT}/installation/docker-amd64-cuda/update-env-file.sh'"; \
    } >> /etc/zsh/zshrc

# Entrypoints.
# The entrypoint is run in an interactive shell so that the conda environment is activated before.
# Don't overwrite the entrypoint, it is installing the project
# and testing that you correctly mounted the project code.
# It also performs some other important setup depending on the deployment platform.
ENV ENTRYPOINTS_ROOT=/opt/template-entrypoints
COPY --link entrypoints ${ENTRYPOINTS_ROOT}
ENTRYPOINT ["/opt/template-entrypoints/pre-entrypoint.sh"]
CMD ["/bin/zsh"]
