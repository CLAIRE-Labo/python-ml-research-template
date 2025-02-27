## Go to the end of the file for useful commands and troubleshooting tips.

# Minimal setup to just ssh into the container.
# For additional options check the readme first, then use from below as examples.

# For RCP use the --pvc claire-scratch:/claire-rcp-scratch
# For IC use the runai-claire-moalla-scratch:/claire-rcp-scratch
runai submit \
  --name example-remote-development \
  --interactive \
  --image registry.rcp.epfl.ch/claire/moalla/template-project-name:amd64-cuda-moalla-latest \
  --pvc runai-claire-moalla-scratch:/claire-rcp-scratch \
  --working-dir /claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_ROOT_AT=/claire-rcp-scratch/home/moalla/template-project-name/dev \
  -e PROJECT_NAME=template-project-name \
  -e PACKAGE_NAME=template_package_name \
  -e SSH_SERVER=1 \
   --allow-privilege-escalation \
  -g 1 --cpu 8 --cpu-limit 8 --memory 64G --memory-limit 64G --large-shm \
  -- sleep infinity

# To request more that the interactive quota add --preemptible to the submit command.

# To mount your gitconfig
#  -e GIT_CONFIG_AT=/claire-rcp-scratch/home/moalla/remote-development/gitconfig \

# For PyCharm
#  -e JETBRAINS_SERVER_AT=/claire-rcp-scratch/home/moalla/remote-development/jetbrains-server \
#  -e PYCHARM_IDE_AT=e632f2156c14a_pycharm-professional-2024.1.4 \

# For VSCode
#  -e VSCODE_SERVER_AT=/claire-rcp-scratch/home/moalla/remote-development/vscode-server \

# For Jupyter Lab
#  -e JUPYTER_SERVER=1 \

# For W&B
#  -e WANDB_API_KEY_FILE_AT=/claire-rcp-scratch/home/moalla/.wandb-api-key \

# For HuggingFace
#  -e HF_TOKEN_AT=/claire-rcp-scratch/home/moalla/.hf-token \
#  -e HF_HOME=/claire-rcp-scratch/home/moalla/huggingface \


## Useful commands.
# runai describe job example-remote-development
# runai logs example-remote-development
# kubectl port-forward example-remote-development-0-0  2222:2223
# ssh runai
# kubectl port-forward example-remote-development-0-0  8888:8888
# runai logs example-remote-development
# Get the link and paste it in your browser, replacing hostname with localhost.

## Troubleshooting.
# When you add a new line for an environment variable or a GPU, etc., remember to add a \ at the end of the line.
# ... \
# -e SOME_ENV_VAR=1 \
# -g 1 \
#...
# -- sleep infinity
