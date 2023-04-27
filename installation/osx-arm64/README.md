# Installation on macOS arm64

## [_DELETE ME_] Template info

This template provides a minimal `environment.yml` file for starting a `conda` environment.
The python version and package name have already been filled by the `fill_template.sh` script.
It remains to

1. Create the environment following the
   user [instructions to install the environment](#instructions-to-install-the-environment).
2. Pin the initial dependencies you just got.
    ```bash
    source installation/osx-arm64/update_env_file.sh 
    ```

You can then add more dependencies as your project grows following
the [instructions to maintain the environment](#instructions-to-maintain-the-environment).

## Instructions to install the environment

**Prerequisites**

- `conda`: we recommend [miniforge](https://github.com/conda-forge/miniforge).

**Installation**

System dependencies:

- None.

Create the environment and activate it.

```bash
conda env create --file installation/osx-arm64/environment.yml
conda activate <project-name>
```

## Instructions to maintain the environment

The dependencies are be managed by both `conda`
and `pip`.
[(Here is a guide for managing `conda` + `pip` environments)](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).

Use `conda` for non-python dependencies (e.g. `swig`) or dependencies packaged with more that just python code (
e.g. `pytorch`).
Use `pip` for pure python dependencies.
Use `pip` as much as possible.

To add `pip` dependencies, just `pip install` them and update the `environment.yml` file with

```bash
source installation/osx-arm64/update_env_file.sh
```

`conda` dependencies should all be installed before any `pip` dependency.
So if you need to add a `conda` dependency after you already installed some `pip` dependencies, you need to recreate
the environment.
For that, add the dependency to the `conda` section of the `environment.yml` file and recreate the environment as in the
previous section.
Then pin the dependencies with

```bash
source installation/osx-arm64/update_env_file.sh
```

You might also need users to install system dependencies.
Use `conda` for those if possible, otherwise specify how to install those in the system dependencies section of
[_Instructions to install the environment_](#instructions-to-install-the-environment).
You could use `brew` or manual build instructions for those.