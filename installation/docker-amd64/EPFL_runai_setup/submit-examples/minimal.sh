runai submit \
  --name example-minimal \
  --interactive \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_ROOT_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -- sleep infinity

## Notes:
# This is a minimal example of a working submission.
# You can then attach a shell to this job with: runai exec -it example-minimal zsh

# The important bits here are:
# The EPFL_RUNAI=1
# The PROJECT_ROOT_IN_PVC env variable must specify the root of the project in your PVC.
# The DATA_DIR_IN_PVC env variable must specify the data directory in your PVC.
# The OUTPUTS_DIR_IN_PVC env variable must specify the outputs directory in your PVC.

## If I wanted my outputs to be in a different PVC I could
# add the the second PVC
#  --pvc runai-mlo-moalla-mloraw1:/mloraw1
# and change the OUTPUTS_DIR_IN_PVC to point to the new PVC
#  --environment OUTPUTS_DIR_IN_OTHER_PVC=/mloraw1/moalla/machrou3/_outputs

# same applies to data directory with DATA_DIR_IN_PVC.
