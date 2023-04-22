runai submit \
  --name example-unattended \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment PROJECT_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/machrou3/dev/_outputs \
  -- python -m my_package.main some_number=2

# or -- python src/my_package/main.py some_number=2
# or -- zsh reproducibility_scripts/some_experiment.sh

# To separate the dev state of the project from frozen checkouts to be used in unattended jobs you can note the
#  -run suffix added to the name of the project directory in the PVC.
# That would be a copy of the my-project repo frozen in commit at a working state to be used in unattended jobs.
# Otherwise while developing I would change the code that would be picked by newly scheduled jobs.
