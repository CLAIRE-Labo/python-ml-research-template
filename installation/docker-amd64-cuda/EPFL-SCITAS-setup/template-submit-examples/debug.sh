
# Change this to the path of your project (can be the /dev or /run copy)
export PROJECT_ROOT_AT=$HOME/template-project-name/dev

# If not done already in your bashrc (depends on the cluster so better write that logic there.)
# export SCRATCH=/scratch/moalla

export FOO=1
export BAR=2

srun -v \
  --container-image=$CONTAINER_IMAGES/claire+moalla+template-project-name+amd64-cuda-moalla-latest.sqsh \
  --container-mounts=$PROJECT_ROOT_AT:$PROJECT_ROOT_AT,$SCRATCH:$SCRATCH  \
  --container-workdir=$PROJECT_ROOT_AT \
  --no-container-mount-home \
  --no-container-remap-root \
  --no-container-entrypoint \
  --container-writable \
  --container-env=FOO \
  --jobid=2163 --overlap \
  --pty /opt/template-entrypoints/pre-entrypoint.sh bash

echo "done"

#  bash -c "echo packages in the container && pip list"

# Here can connect to the container with
# Get the job id (and node id if multinode)
#    
# Connect to the allocation
#   srun --overlap --pty --jobid=JOB_ID
# Inside the job find the container name
#   enroot list
# Exec to the container
#   enroot exec <container-name> zsh


## Useful commands.
# runai describe job example-minimal
# runai logs example-minimal
# runai exec -it example-minimal zsh
