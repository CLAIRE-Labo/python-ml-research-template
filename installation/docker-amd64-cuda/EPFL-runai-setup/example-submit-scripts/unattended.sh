# Minimal setup to just ssh into the container.
# For additional options check the readme first, then use from below as examples.

# For RCP use the --pvc claire-scratch:/claire-rcp-scratch
# For IC use the runai-claire-moalla-scratch:/claire-rcp-scratch

runai submit \
  --name example-unattended \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/run \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/run \
  -e PROJECT_NAME=template-project-name \
  -e PACKAGE_NAME=template_package_name \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G --large-shm \
  -- python -m template_package_name.template_experiment some_arg=2 wandb.mode=offline

# template_experiment is an actual script that you can run.
# or -- zsh template_package_name/reproducibility-scripts/template-experiment.sh

# For W&B
#  -e WANDB_API_KEY_FILE_AT=/claire-rcp-scratch/home/moalla/.wandb-api-key \

# For HuggingFace
#  -e HF_TOKEN_AT=/claire-rcp-scratch/home/moalla/.hf-token \
#  -e HF_HOME=/claire-rcp-scratch/home/moalla/huggingface \


# To separate the dev state of the project from frozen checkouts to be used in unattended jobs you can observe that
# we're pointing to the .../run instance of the repository on the PVC.
# That would be a copy of the template-project-name repo frozen in a commit at a working state to be used in unattended jobs.
# Otherwise while developing we would change the code that would be picked by newly scheduled jobs.

# Useful commands.
# runai describe job example-unattended
# runai logs example-unattended
