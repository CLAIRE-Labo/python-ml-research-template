# Instructions for the data

## [TEMPLATE] Where and how to set up the data

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Update the instructions below to explain how to obtain the data and delete this section.

The template provides the `PROJECT_ROOT/data/` directory as a placeholder for the data used in the project.
This allows the experiment code to always refer to the same path for the data independently of the deployment method
and the user configuration for better reproducibility.
The directory can be accessed in the experiments with `config.data_dir`.
Of course, this doesn't mean that the datasets inside `PROJECT_ROOT/data/` need to be physically in the same directory
as the project.
You can create symlinks to them.
This shifts the data path configuration from the code and config to the installation steps
(which we prefer, as it makes the committed code identical across deployment options).
This is also more convenient than using environment variables to point to individual dataset locations.

Below, you can instruct the users on how to download or link to the data and preprocess it.

When the data is small enough (a few MBs),
you can instruct the users (including you) to download it in the `PROJECT_ROOT/data/` directory.

Otherwise, you can provide hints to them on how to download it (or reuse parts of it) in a separate storage
(likely in a shared storage where some datasets already exist) and then create symlinks to the different parts.
For managed clusters you need to mount different filesystems remember to add this to the deployment scripts
and setup files (e.g. `compose.yaml` for deployment with Docker.)

Here are example instructions:

To setup the `data` directory you can download the data anywhere on your system and then symlink to the data from
the `PROJECT_ROOT/data/` directory.

```bash
# The data set already exist at /absolute_path/to/some-dataset
# FROM the PROJECT_ROOT do
ln -s /absolute-path/to/some-dataset data/some-dataset
# Do this for each dataset root.
# TEMPLATE TODO list all dataset roots (it's better to group them and use the groups accordingly in your code).
```

Be mindful that for the different deployment methods with container engines you will have to mount the filesystems
where the data is stored (E.g. the local deployment option with Docker, and the container deployment on managed clusters)

`TEMPLATE TODO:` For the local deployment option with Docker you would edit the `../installation/docker-*/compose.yaml`
file for the local deployment option with Docker,
for the managed clusters you would edit the flags of the cluster client (`runai`, `srun`, etc.).
Avoid nested mounts.
It's better to mount the whole "scratch" filesystem and let the symlinks handle the rest.

## Description of the data

## Instructions to obtain the data

## Instructions to process the data
