runai submit \
  --name example-minimal \
  --interactive \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_ROOT_IN_PVC=/mlodata1/moalla/my-project \
  -- sleep infinity

### Notes:

# This is a minimal example of a working submission.
# You can then attach a shell to it with: runai exec -it example-minimal zsh
# The EPFL_RUNAI=1 environment variable must be set to setup the paths directory paths correctly.
# The PROJECT_ROOT_IN_PVC environment variable must specify the root of the project in your PVC.

## If I wanted my outputs to be in a different PVC I could add:
#  --pvc runai-mlo-moalla-mloraw1:/mloraw1 \
#  --environment OUTPUTS_DIR_IN_OTHER_PVC=/mloraw1/moalla/my-project/outputs

# same applies to data directory with DATA_DIR_IN_OTHER_PVC: