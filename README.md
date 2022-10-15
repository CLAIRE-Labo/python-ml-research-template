# python-package-template

A template for starting a new Python project, inspired from the
[PyPA packaging tutorial](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
It contains the minimal files needed to start a project with good practices and avoid the common
import workarounds.

Feel free to copy the content of this repository and

1. Fill the template variables in `fill_template.sh` and run the script.

   ```bash
   source fill_template.sh
   ```

2. Edit this `README.md` file.
3. Edit the `LICENCE` file.

## Getting Started

### Installation

We support the following options for installing the project dependencies and running the code.

1. [WIP] Docker:
    - No system dependencies required.
    - Tested on Ubuntu 20.04.
2. Conda directly on your machine:
    - May require you to install system dependencies.
    - Tested on macOS, arm64 (Apple Silicon).

#### 1. [WIP] Docker

#### 2. Conda directly on your machine:

Prerequisites

- `conda`: we recommend [miniforge](https://github.com/conda-forge/miniforge).

Create the environment:

```bash
source installation/conda/create_env.sh
```

Install the dependencies:

_System dependencies:_
We provide a way to install most of the system dependencies via conda, but we may miss some and
depending on your system you may still need to install other ones.
Feel free to use this script or install the system dependencies on your machine directly.

```bash
conda install --file installation/conda/system_dependencies.txt
````

_The rest of the dependencies:_
The dependencies will be packaged by both `conda` and `pip`
. [(Here is a guide for managing `conda` + `pip` environments)](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#using-pip-in-an-environment)
.

```bash
source installation/conda/install_dependencies.sh
```

Install your package

```bash
pip install -e .
```