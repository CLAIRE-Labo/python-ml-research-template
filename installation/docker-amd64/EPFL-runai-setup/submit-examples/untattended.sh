runai submit \
  --name example-unattended \
  --image ic-registry.epfl.ch/claire/template-project-name/moalla:latest-runtime \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  -e EPFL_RUNAI=1 \
  -e PROJECT_DIR_IN_PVC=/claire-rcp-scratch/home/moalla/template-project-name/run \
  -- python -m template_package_name.some_experiment some_arg=2

# or -- python template-project-name/src/template_package_name/some_experiment.py some_number=2
# or -- zsh template_package_name/reproducibility_scripts/some_experiment.sh

# To separate the dev state of the project from frozen checkouts to be used in unattended jobs you can observe that
# I'm pointing to the /run instance of my repository on my PVC.
# That would be a copy of the template-project-name repo frozen in a commit at a working state to be used in unattended jobs.
# Otherwise while developing I would change the code that would be picked by newly scheduled jobs.

# Useful commands.
# runai describe job example-unattended
# runai logs example-unattended
