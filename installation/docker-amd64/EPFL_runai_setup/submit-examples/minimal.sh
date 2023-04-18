runai submit \
  --name example-minimal \
  --interactive \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment CODE_DIR_IN_PVC=/mlodata1/moalla/my-project/code \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/my-project/data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/my-project/outputs \
  -- sleep infinity

### Notes:

# This is a minimal example of a working submission.
# The code, data, and outputs directories must be specified.

## If I wanted my outputs to be in a different PVC I could do:
#  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
#  --pvc runai-mlo-moalla-mloraw1:/mloraw1 \
#  --environment CODE_DIR_IN_PVC=/mlodata1/moalla/my-project/code \
#  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/my-project/data \
#  --environment OUTPUTS_DIR_IN_PVC=/mloraw1/moalla/my-project/outputs
