runai submit \
  --name example-minimal \
  --interactive \
  --image ic-registry.epfl.ch/claire/template-project-name/moalla:latest-dev \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -- sleep infinity

## Notes:
# This is a minimal example of a working submission.
# You can then attach a shell to this job with: runai exec -it example-minimal zsh

# The important bits here are:
# -e EPFL_RUNAI=1
# -e PROJECT_DIR_IN_PVC must specify the project directory in your PVC.

## If I wanted my data to be in a different PVC I could
# 1. add the the second PVC
#  --pvc runai-claire-moalla-nas:/claire-rcp-nas \
# 2. Add the DATA_DIR_IN_PVC to point to the new PVC
#  -e DATA_DIR_IN_PVC=/claire-rcp-nas/home/moalla/template-project-name/dev/_data

# The same applies to the outputs directory with OUTPUTS_DIR_IN_PVC.

## Useful commands.
# runai describe job example-minimal
# runai logs example-minimal
# runai exec -it example-minimal zsh
