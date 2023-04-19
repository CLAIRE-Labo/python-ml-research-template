runai submit \
  --name example-first-steps \
  --interactive \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment SSH_ONLY=1 \
  -- sleep infinity

# This will start an ssh server in the container, without setting the paths for your project.
