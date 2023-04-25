runai submit \
  --name example-minimal \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -- sleep infinity

## Notes:
# This is a minimal example of a working submission.
# You can then attach a shell to this job with: runai exec -it example-minimal zsh

# The important bits here are:
# --environment EPFL_RUNAI=1
# --environment PROJECT_DIR_IN_PVC must specify the project directory in your PVC.
# --environment DATA_DIR_IN_PVC must specify the data directory in your PVC.
# --environment OUTPUTS_DIR_IN_PVC must specify the outputs directory in your PVC.
# In the example I'm using the default placeholder _data and _outputs directories of the project.

## If I wanted my outputs to be in a different PVC I could
# 1. add the the second PVC
#  --pvc runai-mlo-moalla-mloraw1:/mloraw1
# 2. change the OUTPUTS_DIR_IN_PVC to point to the new PVC
#  --environment OUTPUTS_DIR_IN_PVC=/mloraw1/moalla/machrou3/dev/_outputs

# The same applies to the data directory with DATA_DIR_IN_PVC.
