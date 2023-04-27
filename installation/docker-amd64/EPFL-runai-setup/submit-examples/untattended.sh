runai submit \
  --name example-unattended \
  --image ic-registry.epfl.ch/mlo/machrou3/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/run \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/run/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/run/_outputs \
  -- python -m machrou3.main some_number=2

# or -- python machrou3/src/machrou3/main.py some_number=2
# or -- zsh machrou3/reproducibility_scripts/some_experiment.sh

# To separate the dev state of the project from frozen checkouts to be used in unattended jobs you can observe
# I'm pointing to the /run instance of my repository on my PVC.
# That would be a copy of the machrou3 repo frozen in a commit at a working state to be used in unattended jobs.
# Otherwise while developing I would change the code that would be picked by newly scheduled jobs.

# Useful commands.
# runai describe job example-unattended
# runai logs example-unattended
