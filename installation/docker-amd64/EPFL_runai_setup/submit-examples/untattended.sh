runai submit \
  --name example-unattended \
  --image ic-registry.epfl.ch/mlo/my-project/moalla:latest \
  --pvc runai-mlo-moalla-mlodata1:/mlodata1 \
  --environment EPFL_RUNAI=1 \
  --environment CODE_DIR_IN_PVC=/mlodata1/moalla/my-project-run/code \
  --environment DATA_DIR_IN_PVC=/mlodata1/moalla/my-project-run/data \
  --environment OUTPUTS_DIR_IN_PVC=/mlodata1/moalla/my-project-run/outputs \
  -- python -m my_project.main some_number=2


# To separate the dev state of the project from frozen checkouts to be used in unattended jobs you can note the
#  -run suffix added to the name of the project directory in the PVC.
# That would be a copy of the my-project repo frozen in commit at a working state to be used in unattended jobs.
# Otherwise while developing I would change the code that would be picked by newly scheduled jobs.