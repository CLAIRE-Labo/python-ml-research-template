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
This shifts the data path configuration from the code and config,
which we prefer to be identical across deployment options,
to the installation steps.
This is also more convenient than using environment variables to point to individual dataset locations.

Below, you can instruct the users on how to download or link to the data and preprocess it.

When the data is small enough, you can instruct the users to download it in the `PROJECT_ROOT/data/` directory.
Otherwise, you can provide hints to them on how to download it (or reuse parts of it) in separate storages
(potentially in a shared storage where some datasets already exist) and then create symlinks to it.
As these instructions to use separate storage will depend on the installation method, we advise moving
them to the `installation/*/README.md` file after the development environment installation instructions.
You can link back to this file for common instructions and information about download links.

* For the local conda installation method, this is only symlinks to other locations in the local filesystem. E.g.
  ```bash
  # The data set already exist at /absolute_path/to/some-dataset
  # FROM the PROJECT_ROOT do
  ln -s /absolute-path/to/some-dataset data/some-dataset
  ```
* For the local deployment option with Docker, and the container deployment on managed clusters,
  in addition to symlinks, you naturally have to mount the storage where the symlinks points to.
  The symlink would look like:
   ```bash
  # Make sure to consistently mount the volume with in the same location.
  # The data set already exist at  /absolute-path-in-the-mounted-volume/to/some-dataset
  # FROM the PROJECT_ROOT do
  ln -s /absolute-path-in-the-mounted-volume/to/some-dataset data/some-dataset
  ```
  And you would edit the `../installation/docker-*/compose.yaml` file for the local deployment option with Docker,
  otherwise the flags of the cluster client for the managed clusters.
  mount the individual datasets inside the `PROJECT_ROOT/data/` directory. Avoid nested mounts.
  Otherwise, you can do like the option below, to mount every shared dataset directory somewhere and symlink to them.
  (Note: we use symlinks in this case as well to avoid nested mounts which can cause issues.)

## Description of the data

## Instructions to obtain the data

## Instructions to process the data
