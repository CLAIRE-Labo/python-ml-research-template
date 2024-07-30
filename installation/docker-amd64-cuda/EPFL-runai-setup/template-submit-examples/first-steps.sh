runai submit \
  --name example-first-steps \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e SSH_SERVER=1 \
  --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G \
  -- sleep infinity

## Notes:
# This will start an ssh server in the container, without setting up your project
## The important bits here are:
# 1.The command to mount your pcv.
# --pvc your_pvc_name:/where_to_mount_your_pvc (you can mount it anywhere)
# we recommend always mounting it inside the / directory always with the same name.
# 2. the environment variables that configure the entrypoint.
# -e SSH_SERVER=1 will make the entrypoint start an ssh server.

## Useful commands.
# runai describe job example-first-steps
# runai logs example-first-steps
# kubectl port-forward example-first-steps-0-0  2222:2223
# If you setup your ssh config you can then
# ssh local2222
