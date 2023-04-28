# Installation on macOS arm64

## [TEMPLATE] Template info

This template provides a minimal `environment.yml` file for starting a `conda` environment.
The python version and package name have already been filled by the `fill_template.sh` script.
It remains to

1. Create the environment following the
   user [instructions to install the environment](#instructions-to-install-the-environment).
2. Pin the initial dependencies you just got.
    ```bash
    source installation/osx-arm64/update_env_file.sh 
    ```
   You can later add more dependencies as your project grows following
   the [instructions to maintain the environment](#instructions-to-maintain-the-environment).
3. Delete the [TEMPLATE] sections from this file.

## Instructions to install the environment

**Prerequisites**

- `brew`: [Homebrew](https://brew.sh/).
- `mamba` (or equivalently `conda`): we recommend [Mambaforge](https://github.com/conda-forge/miniforge).

**Installation**

System dependencies:

- None.

The `conda` environment:

```bash
mamba env create --file installation/osx-arm64/environment.yml
mamba activate <package_name>
```

## Instructions to maintain the environment

System dependencies are managed by `conda`, otherwise `brew` (we try to keep everything self-container as much as
possible).
Python dependencies are be managed by both `conda` and `pip`.

- Use `conda` for system and non-python dependencies needed to run the project code (e.g.`swig`).
  If not available on `conda` use `brew`.
- Use `conda` for python dependencies packaged with more that just python code (e.g. `pytorch`, `numpy`).
  These will typically be your main dependencies and will likely not change as your project grows.
- Use `pip` for the rest of the python dependencies.
- For more complex dependencies that may require a custom installation or build, manually follow their installation
  steps.

Here are references and reasons to follow the above claims:

* [A guide for managing `conda` + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to  use `conda` for not-python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining `conda` and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

There are two ways to add dependencies to the environment:

1. **Manually edit the dependencies files.**
   This will be needed the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell with the environment activated
   to experiment with which dependency is needed.
   This is probably what you'll be doing after building the image for the first time.

In both cases, after any change, a snapshot of the full environment specification should be saved.
We describe how to do so in the freeze the environment section.

### Manual editing (before/while building)

- To edit the `conda` and `pip` dependencies, edit the `environment.yml` file.
- For the `brew` and more complex dependencies, describe the installation steps in the
  [Instructions to install the environment](#instructions-to-install-the-environment) section.

When manually editing the `environment.yml` file, you do not need to specify the specific version of the dependencies,
these will be written to the file when you freeze the environment.
You will only need to specify the major versions of specific dependencies you need.

### Interactively (while developing)

`conda` dependencies should all be installed before any `pip` dependency.
This will cause conflicts otherwise as `conda` doesn't track the `pip` dependencies.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to
manually add the dependency to the `environment.yml` file then recreate the environment.

* To add `conda` dependencies run `(conda | pip) install <package>`
* To add a `brew`  dependency run `brew install <package>`

### Freeze the environment

After any change to the dependencies, a snapshot of the full environment specification should be written to the
`environment.yml` file.
This includes changes during a build and changes made interactively.
This is to ensure that the environment is reproducible and that the dependencies are tracked at any point in time.

To do so, run the following command.
The script overwrites the `environment.yml` file with the current environment specification,
so it's a good idea to commit the changes to the environment file before/after running it.

```bash
source installation/osx-arm64/update_env_file.sh
```

For `brew` and more complex dependencies describe how to install them in the system dependencies section of
the [instructions to install the environment](#instructions-to-install-the-environment).

## Troubleshooting
