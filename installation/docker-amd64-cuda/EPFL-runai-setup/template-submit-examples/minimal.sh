runai submit \
  --name example-minimal \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
  -- sleep infinity

## Notes:
# This is a minimal example of a working submission.
# You can then attach a shell to this job with: runai exec -it example-minimal zsh

# The important bits here are:
# 1.The command to mount your pcv.
# --pvc your_pvc_name:/where_to_mount_your_pvc (you can mount it anywhere)
# 2.The environment variables that tell the entrypoint where to find your project.
# -e PROJECT_ROOT_AT=<location of your project in your mounted PVC> .
# 3.The working directory set to the PROJECT_ROOT_AT.
# --working-dir same as PROJECT_ROOT_AT.

## Useful commands.
# runai describe job example-minimal
# runai logs example-minimal
# runai exec -it example-minimal zsh
