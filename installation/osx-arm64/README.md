# Installation on macOS arm64

## Template getting started

> [!IMPORTANT] 
> **TEMPLATE TODO:**
> Follow the instructions then delete this section.

This template provides a minimal `environment.yml` file for starting a `conda` environment.
The Python version and package name have already been filled by the `fill_template.sh` script.
It remains to

1. Specify your initial dependencies.
   Follow the [instructions to maintain the environment](#maintaining-the-environment)
   up to (including) the manual editing section without actually creating the environment.
   Commit so that you can get back to this file to edit it manually.
2. Create the environment following the user
   [instructions to create the environment](#creating-the-environment) below.
3. Get familiar with running the environment following the user [instructions to
   run the environment](#running-the-code-in-the-environment).
4. If everything works fine, (we suggest trying to import your dependencies and running simple scripts), then
   pin the dependencies you just got following the [freeze the environment](#freeze-the-environment) section.
   You can then add more dependencies as your project grows following
   the [instructions to maintain the environment](#maintaining-the-environment).
   Commit.
5. Delete this [TEMPLATE]-prefixed section from this file.

## Cloning the repository

The project follows a specific tree structure that needs to be followed for the installation to work.

```
template-project-name/          # To which we will refer as the PROJECT_ROOT can be any directory name.
├── template-project-name/      # This is the git repository root.
├── data/                # This is from where the data will be read.
├── outputs/             # This is where the outputs will be written.
└── wandb/               # This is where wandb artifacts will be written.
```

Create the respective directories so that the tree looks like the above:

> [!IMPORTANT] 
> **TEMPLATE TODO:**
> If you're setting up the template and already cloned the repository, replace 1. and 2. below with the following
> ```bash
> # When in the repository root.
> mkdir template-project-name
> mv {.,}* template-project-name
> # Ignore the error message.
>  ```
> Be careful, moving all files with `mv *` does not move the dotfiles, so will miss the git
> files.
>
> Delete this note.

1. Create the `PROJECT_ROOT` directory.
   ```bash
   mkdir template-project-name && cd template-project-name
   ```
2. Clone the git repository in the `PROJECT_ROOT` directory.
   ```bash
   git clone <URL/SSH> template-project-name
   ```
3. Symlink `data/`, `outputs/`, and `wandb/` to the placeholder `_data/`, `_outputs/`, and `_wandb/`
   directories we created in the repository root.
   ```bash
   # When in the PROJECT_ROOT directory.
   ln -s $(pwd)/template-project-name/_data data
   ln -s $(pwd)/template-project-name/_outputs outputs
   ln -s $(pwd)/template-project-name/_wandb wandb
   ```

## Creating the environment

**Prerequisites**

- `brew`: [Homebrew](https://brew.sh/).
- `mamba` (or equivalently `conda`): we recommend [Mambaforge](https://github.com/conda-forge/miniforge).

**Installation**

System dependencies:

- None.

The `conda` environment:

```bash
# When in the PROJECT_ROOT directory.
mamba env create --file template-project-name/installation/osx-arm64/environment.yml
```

## Running the code in the environment

```bash
mamba activate template-project-name
```

Run your scripts from the `PROJECT_ROOT` directory.
Here are some examples.

```bash
# When in the PROJECT_ROOT directory.
python template-project-name/src/template_package_name/some_experiment.py some_arg=some_value
python -m template-project-name.some_experiment some_arg=some_value
source template-project-name/reproducibility_scripts/some_experiment.sh
```

## Maintaining the environment

System dependencies are managed by `conda`, otherwise `brew` (we try to keep everything self-container as much as
possible).
Python dependencies are be managed by both `conda` and `pip`.

- Use `conda` for system and non-Python dependencies needed to run the project code (e.g.`swig`).
  If not available on `conda` use `brew`.
- Use `conda` for Python dependencies packaged with more that just Python code (e.g. `pytorch`, `numpy`).
  These will typically be your main dependencies and will likely not change as your project grows.
- Use `pip` for the rest of the Python dependencies (e.g. `tqdm`).
- For more complex dependencies that may require a custom installation or build,
  manually follow their installation steps.

Here are references and reasons to follow the above claims:

* [A guide for managing `conda` + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to  use `conda` for not-Python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining `conda` and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

There are two ways to add dependencies to the environment:

1. **Manually edit the dependencies files.**
   This will be needed the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell with the environment activated
   to experiment with which dependency is needed.
   This is probably what you'll be doing after creating the image for the first time.

In both cases, after any change, a snapshot of the full environment specification should be saved.
We describe how to do so in the freeze the environment section.

### Manual editing (before/while building)

- To edit the `conda` and `pip` dependencies, edit the `environment.yml` file.
- For the `brew` and the more complex dependencies, describe the installation steps in the
  [Development Environment](#development-environment) section.

When manually editing the `environment.yml` file, you do not need to specify the specific version of the dependencies,
these will be written to the file when you freeze the environment.
You can of course specify the major versions of specific dependencies you need.

After manually editing the `environment.yml` file, you need to recreate the environment.

```bash
# When in the PROJECT_ROOT directory.
mamba deactivate
mamba env remove --name template-project-name
mamba env create --file template-project-name/installation/osx-arm64/environment.yml
mamba activate template-project-name
```

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
This includes manual changes to the file and changes made interactively.
This is to ensure that the environment is reproducible and that the dependencies are tracked at any point in time.

To do so, run the following command.
The script overwrites the `environment.yml` file with the current environment specification,
so it's a good idea to commit the changes to the environment file before and after running it.

```bash
# When in the PROJECT_ROOT directory.
source template-project-name/installation/osx-arm64/update_env_file.sh
```

For `brew` and more complex dependencies describe how to install them in the system dependencies section of
the [instructions to install the environment](#instructions-to-install-the-environment).

## Troubleshooting
