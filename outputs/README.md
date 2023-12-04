# Instructions for the outputs (models weights, logs, etc.)

## [TEMPLATE] Where and how to set up the outputs

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Update the instructions below to explain how to obtain the outputs and delete this section.

The template provides the `PROJECT_ROOT/outputs/` directory as a placeholder for the outputs generated in the project
(model weights, logs, etc.).
This allows the experiment code to always refer to the same path for the outputs independently of the deployment method
for better reproducibility.
The output directories in `PROJECT_ROOT/outputs/` don't need to be physically in the same directory
as the project, you can create symlinks to them.
The default setup config `src/template_package_name/configs/setup.yaml` defines an outputs subdirectory where it will
save the outputs.
This is by default `PROJECT_ROOT/outputs/dev` (so you can symlink that location to somewhere else).
This design shifts the outputs' path configuration from the code and config which should be identical across runs
to the installation steps where you will create your symlinks.
This is also more convenient than using environment variables to point to individual output locations.

Below, you can instruct the users on how to link/download the outputs you generated
to directly use them for reproducibility.
Refer to the [data instructions](../data/README.md) for example instructions.

## Description of the outputs

## Instructions to obtain the outputs
