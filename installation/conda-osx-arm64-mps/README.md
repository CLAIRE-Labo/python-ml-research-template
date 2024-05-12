# Installation with conda

## Template getting started

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Follow the instructions then delete this section.

This template provides a minimal `environment.yml` file for setting a conda environment.
Follow the steps below to get started.
Some steps will send you to different sections of the document.
It may feel like jumping back and forth, but everything should read nicely after the setup
for your future users (and yourself).

1. Choose the platform and hardware acceleration that you will build the environment for.
   You have to pick one as fully specified conda environment files are not trivially
   portable across platforms and hardware accelerations.
   Packages are different for different platforms and hardware accelerations,
   so you cannot freeze an environment used for a platform and create it in another.

   The default platform is macOS on Apple Silicon `osx-arm64` to get support for `mps` hardware acceleration
   (reflected in the name of the directory `conda-osx-arm64-mps` by default).
   To edit it, run
   ```bash
   # When in the PROJECT_ROOT directory.
   # For examples run:
   ./installation/edit-platform-and-acceleration.sh
   # To do the change run:
   ./installation/edit-platform-and-acceleration.sh change conda CURR_PLATFORM CURR_ACCELERATION NEW_PLATFORM NEW_ACCELERATION
   # For a list of available platforms you can see the installers below
   # https://anaconda.org/pytorch/pytorch
   # The hardware acceleration will be determined by the packages you install.
   # E.g. if you install PyTorch with CUDA, set the acceleration to cuda.
   ```
   If you plan to support multiple platforms or hardware accelerations,
   you can duplicate this installation method directory
   with `./installation/edit-platform-and-acceleration.sh copy ...`
   then perform the setup again.
2. You can try to specify your dependencies if you are sure of how to install them and that they are compatible.
   Otherwise, you should build with the default dependencies and install them interactively in the running container
   then freeze them in the dependency files once you are sure of which to include and how to include them.
   You will find more information in the [instructions to maintain the environment](#from-python-instructions-to-maintain-the-environment).
   The Python version and package name have already been filled by the `fill-template.sh` script.

   If you change the dependency files commit so that you can track what worked and what didn't.
3. Create the environment following the user
   [instructions to create the environment](#creating-the-environment) below.
4. Get familiar with running the environment following the user [instructions to
   run the environment](#running-the-code-in-the-environment).
5. If everything works fine,
   (we suggest checking that all of your dependencies are there with `mamba list`,
   and trying to import the important ones),
   then pin the dependencies you got following the [freeze the environment](#freeze-the-environment) section.
   You can then add more dependencies as your project grows following
   the [instructions to maintain the environment](#maintaining-the-environment).
   Commit.
6. Go back to the root README for the rest of the instructions to set the template up.

## Cloning the repository

Clone the git repository.

```bash
git clone <HTTPS/SSH> template-project-name
cd template-project-name
```

We will refer the absolute path to the root of the repository as `PROJECT_ROOT`.

## Creating the environment

**Prerequisites**

- `brew`: [Homebrew](https://brew.sh/).
- `mamba` (or equivalently `conda`): we recommend [Miniforge](https://github.com/conda-forge/miniforge).

**Installation**

System dependencies:

We list below the important system dependencies that are not available in conda,
but it is hard to list all the system dependencies needed to run the code.
We let you install the missing ones when you encounter errors.

- None.

The conda environment:

Create the environment with

```bash
# When in the PROJECT_ROOT directory.
mamba env create --file installation/conda-osx-arm64-mps/environment.yml
```

Install the project with

```bash
# Activate the environment
mamba activate template-project-name
# When in the PROJECT_ROOT directory.
pip install -e .
```

## Running code in the environment

```bash
mamba activate template-project-name
```

Run scripts from the `PROJECT_ROOT` directory.
Here are some examples.

```bash
# When in the PROJECT_ROOT directory.
# template_experiment is an actual script that you can run.
python -m template_package_name.template_experiment some_arg=some_value
zsh reproducibility-scripts/template-experiment.sh
```

The environment is set up.
Return to the root README for the rest of the instructions to run our experiments.

## Maintaining the environment

System dependencies are managed by conda, otherwise when not available, by brew.
(We try to keep everything self-container as much as possible.)
Python dependencies are managed by both conda and pip.

- Use `conda` for system and non-Python dependencies needed to run the project code (e.g., image libraries, etc.).
  If not available on conda use `brew`.
- Use `conda` for Python dependencies packaged with more that just Python code (e.g. `pytorch`, `numpy`).
  These will typically be your main dependencies and will likely not change as your project grows.
- Use `pip` for the rest of the Python dependencies (e.g. `tqdm`).
- For more complex dependencies that may require a custom installation or build,
  manually follow their installation steps.

Here are references and reasons to follow the above claims:

* [A guide for managing conda + `pip` environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment).
* [Reasons to use conda for not-Python-only dependencies](https://numpy.org/install/#numpy-packages--accelerated-linear-algebra-libraries).
* [Ways of combining conda and `pip`](https://towardsdatascience.com/conda-essential-concepts-and-tricks-e478ed53b5b#42cb).

There are two ways to add dependencies to the environment:

1. **Manually edit the `environment.yml` file.**
   This is used the first time you set up the environment.
   It will also be useful if you run into conflicts and have to restart from scratch.
2. **Add/upgrade dependencies interactively** while running a shell with the environment activated
   to experiment with which dependency is needed.
   This is probably what you'll be doing after creating the environment for the first time.

In both cases, after any change, a snapshot of the full environment specification should be saved.
We describe how to do so in the freeze the environment section.
Remember to commit the changes every time you freeze the environment.

### Manual editing (before/while building)

- To edit the conda and pip dependencies, edit the `environment.yml` file.
- For the `brew` and the more complex dependencies, describe the installation steps in the
  [Creating the environment](#creating-the-environment) section.

When manually editing the `environment.yml` file,
you do not need to specify the version of all the dependencies,
these will be written to the file when you freeze the environment.
You should just specify the major versions of specific dependencies you need.

After manually editing the `environment.yml` file, you need to recreate the environment.

```bash
# When in the PROJECT_ROOT directory.
mamba deactivate
mamba env remove --name template-project-name
mamba env create --file installation/conda-osx-arm64-mps/environment.yml
mamba activate template-project-name
```

### Interactively (while developing)

Conda dependencies should all be installed before any `pip` dependency.
This will cause conflicts otherwise as conda doesn't track the `pip` dependencies.
So if you need to add a conda dependency after you already installed some `pip` dependencies, you need to
manually add the dependency to the `environment.yml` file then recreate the environment.

* To add conda/pip dependencies run `(mamba | pip) install <package>`
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
zsh installation/conda-osx-arm64-mps/update-env-file.sh
```

There are some caveats (e.g., packages installed from GitHub with pip), so have a look at
the output file to make sure it does what you want.
The `update-env-file.sh` gives some hints for what to do, and in any case you can always patch the file manually.

For `brew` and more complex dependencies describe how to install them in the system dependencies section of
the [instructions to install the environment](#creating-the-environment).

If one of the complex dependencies shows in the `environment.yml` after the freeze,
you have to remove it, so that conda does not pick it up, and it is installed later by the user.

## Troubleshooting
