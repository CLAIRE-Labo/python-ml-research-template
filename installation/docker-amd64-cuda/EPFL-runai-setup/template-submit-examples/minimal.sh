runai submit \
  --name example-minimal \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-run-latest-moalla \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -- sleep infinity

## Notes:
# This is a minimal example of a working submission.
# You can then attach a shell to this job with: runai exec -it example-minimal zsh

# The important bits here are:
# 1.The command to mount your pcv.
# --pvc your_pvc_name:/where_to_mount_your_pvc (you can mount it anywhere)
# 2.The environment variables that tell the entrypoint where to find your project.
# -e PROJECT_ROOT_AT=<location of your project in your mounted PVC> .

# Note that here we are using the run image (run-latest-moalla)
# There is no need to use the dev images when not planing to develop in the container.
# The run image is typically smaller and can be scaled to run more jobs.

## Useful commands.
# runai describe job example-minimal
# runai logs example-minimal
# runai exec -it example-minimal zsh
