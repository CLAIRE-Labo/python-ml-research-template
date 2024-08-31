# To enable the hooks (done by the [annotations] in the edf.toml file)
# export the right env variables read by the hooks in /etc/enroot/hooks.d/... at the beginning of this file.
# (refs: https://github.com/NVIDIA/enroot/blob/master/doc/configuration.md#pre-start-hook-scripts)
# https://github.com/NVIDIA/enroot/blob/master/doc/cmd/start.md#description)
# E.g., OCI_ANNOTATION_com__hooks__aws_ofi_nccl__enabled=true used by 90-aws-ofi-nccl.sh

# To enable the env vars (done by the [env] in the edf.toml file) echo the variables in the environ() function.
# Here we enable the same hooks and env vars as edf.toml

# Also note the by default Pyxis keep all the env variables of the host in the container.
# enroot does not do it by default we attempt to do this in the environ() function.


# From edf.toml [annotations]
export OCI_ANNOTATION_com__hooks__aws_ofi_nccl__enabled=true
export OCI_ANNOTATION_com__hooks__aws_ofi_nccl__variant=cuda12

environ() {
    # From edf.toml [env]
    echo 'FI_CXI_DISABLE_HOST_REGISTER="1"'
    echo 'FI_MR_CACHE_MONITOR="userfaultfd"'
    echo 'NCCL_DEBUG="INFO"'
    # Keep all the environment from the host
    # Filters weird stuff, may need to be adapted
    env | grep -v -E '^(BASH|PROMPT_COMMAND|SHLVL|PWD|OLDPWD|SHELL|LOGNAME|_| |\}|\{)' |\
    sed -E 's/=(.*)/="\1"/'
}

#mounts() {}

#hooks() {}

#rc() {}
