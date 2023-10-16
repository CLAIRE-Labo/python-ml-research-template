# Instructions for the Data

## [TEMPLATE] Where and how to set up the data

The template has a common directory structure across all installation methods.
(More info on the directory structure in the `template/README.md` file.).

  ```text
  PROJECT_ROOT/ # Will be /somewhere/PROJECT_NAME/ on the Apple Silicon option and /opt/project/ on the Docker options.
  ├── template-project-name/ # The root of the the git repository.
  ├── data/    # This is from where the data will be read.
  ├── outputs/ # This is where the outputs will be written.
  └── wandb/   # This is where wandb artifacts will be written.
  ```

By default, the `data/` `outputs/` and `wandb/` directories
are symlinks to or mount the `_data/` `_outputs/` and `_wandb/` directories, so you if your datasets
are small enough, you can store them directly in `_data/` and they will be exposed in the `data/` directory.
You can then easily instruct your users in the following sections to do the same.

Otherwise, if your datasets are very large and spread across filesystems, say you share them with your team,
you will have to follow different steps depending on the installation method.

* For the local deployment option with Docker, you can edit the `../installation/docker-amd64/compose.yaml` and
  `../installation/docker-amd64/template.sh` files to mount the individual datasets inside the `DATA_DIR` directory.
  Comments are left in those files to guide you.
* For managed clusters like the EPFL IC Run:ai cluster, you can mount all the PVCs where you have
  your datasets then edit the
  `../installation/docker-amd64/EPFL-runai-setup/setup.sh` file so that it creates symlinks inside `DATA_DIR`
  to the datasets inside the mounted PVCs.
  Make the PVC locations configurable with environment variables as we did with the `*_DIR_IN_PVC` variables.
* For the Apple Silicon option, you can create individual symlinks to the datasets inside the `_data/` directory,
  or mount them there.
  They will then be exposed in the `data/` directory as well.

As these instructions will depend on the installation method we advise moving them to the `installation/*/README.md`
file after the development environment installation instructions.
You can always link back to this file for common instructions and information such as download links and steps.

We will provide example projects where we have done this.

> [TEMPLATE] UPDATE ME then DELETE ME:
> Update the instructions below to explain how to obtain the data and delete this section.

## Instructions to obtain the data

## Instructions to process the data

## Description of the data
