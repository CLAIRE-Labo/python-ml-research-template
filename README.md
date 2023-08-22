# Python Machine Learning Research Project Template

## Overview

This is a template used for starting Python machine-learning research
projects with hardware acceleration at the EPFL CLAIRe (tentative name) lab.
It features and encourages good practices for:

- Reproducible environments that run and provide a good development experience on multiple platforms with hardware
  acceleration.
  Including:
    - local machines (macOS + Apple Silicon, WSL + GPU),
    - Linux servers (VMs on cloud providers, HaaS from EPFL IC),
    - the EPFL IC RunAI Kubernetes cluster (and soon other cloud services like GCP Vertex AI, AWS SageMaker).
- Experiment management, tracking, and sharing with [Hydra](https://hydra.cc/)
  and [Weights & Biases](https://wandb.ai/site).
- Python project packaging following the
  [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- Code quality with [pre-commit](https://pre-commit.com) hooks.

Thanks to its focus on reproducibility, this template can readily be used by other labs at EPFL and beyond.
With this template, sharing your work will be a breeze, and its adoption will be straightforward,
maximizing its impact.
The practices in this template earned its authors
an [Outstanding Paper (Honorable Mention)](https://openreview.net/forum?id=E0qO5dI5aEn) at the
[ML Reproducibility Challenge 2022](https://paperswithcode.com/rc2022).

The template can also be adapted to suit many other use cases, however, its maintained form will be tailored to the
needs of CLAIRe.
It also contains extra EPFL-specific instructions for deployment on the EPFL RunAI Kubernetes cluster.
For more information on the template and a discussion of its design choices see the `template/README.md` file.

## Getting started with the template

Click on the `Use this template` GitHub button to create a new GitHub repository from this template.
Give it a (hyphen-separated) name, then follow the instructions below to set up your project.
It's useful to commit after some checkpoints to be able to go back if you make a mistake.

1. Clone the repo.
2. Fill the template variables in `template/template_variables.env` and run the script
   ```bash
   ./template/fill_template.sh
   ```
   Then delete the `template` directory and commit.

3. Edit the `LICENCE` file.
   Or delete it and remember to add one when open-sourcing your code.
   [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT license is to replace the `2022 Skander Moalla` with your year and name.
   Commit.
4. Set up and edit the development environment instructions for the platforms you will use and support.
   We support shared instructions for:
    - **AMD64 platforms (x86-64)** to run on Linux servers like the EPFL HaaS servers, WSL on locals machines,
      Kubernetes clusters like the EPFL RunAI cluster and other cloud services, and supports for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`.
    - **macOS with Apple Silicon (`osx-arm64`)** with support for MPS hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.

   Delete the installation directory for the platforms you don't use.

   In addition, it is good to list your direct dependencies (with major versions when relevant)
   for users with other needs.
   This is described in the next instructions in the [development environment](#development-environment) section.
5. Edit this `README.md` file.
    1. Edit the title with the name of your project.
       Replace the [Overview](#overview) section with a description of your project.
    2. Delete the installation options you don't support in
       the [Getting Started](#getting-started) section.
    3. List your direct dependencies (with major versions when relevant)
       in the [Getting Started](#getting-started) section.
    4. If you use datasets, describe how to obtain them in the [datasets](#datasets) section.
       You can refer the users to `_data/README.md` and write the instructions there.
       The template has a common directory structure across all installation methods.
       So you should ask the users to put the data somewhere in the `data/` directory.
       (More info on the directory structure in the `template/README.md` file.).
       ```
       PROJECT_ROOT/        # The root of the project can be any name.
       ├── <project-name>/  # The root of the the git repository.
       ├── data/            # This is from where the data will be read (will mount/symlink to somewhere by the user).
       ├── outputs/         # This is where the outputs will be written (will mount/symlink to somewhere by the user).
       └── wandb/           # This is where wandb artifacts will be written.
       ```
       Otherwise, delete the section.
    5. Delete this getting started, to only keep the project [Getting Started](#getting-started) section.

You're off to a good start! Here are a few tips for keeping your project in good shape.

- Keep this README up to date.
  Fill in the rest of the sections after the Getting Started when releasing your project.
  We give a structure and some templates for those.
- Remember to pin your dependencies whenever you install new ones.
  More on this in the installation guides.
- Keep your `reproducibility_scripts/` directory up to date.
  Commit it regularly and run your jobs with those scripts.
  More on this in the [Reproducibility](#reproducibility) section.
- Maintain good commit hooks. More on this in the [Contributing](#contributing) section.
- Have a look at the [ML Code Completeness Checklist](https://github.com/paperswithcode/releasing-research-code).
  This template facilitates meeting all the checklist items, with a different design.

## Getting Started

### Development environment

We support the following platforms for installing the project dependencies and running the code.

- **AMD64 platforms (x86-64)** to run on Linux servers like the EPFL HaaS servers, WSL on locals machines,
  Kubernetes clusters like the EPFL RunAI cluster and other cloud services, and supports for NVIDIA GPUs.
  Refer to `installation/docker-amd64/README.md`.
- **macOS with Apple Silicon (`osx-arm64`)** with support for MPS hardware acceleration.
  Refer to `installation/osx-arm64/README.md`.

We list below our direct dependencies (with major versions when relevant) for users with other needs.

```text
Python <python-version>

Python packages:
wandb
hydra
tqdm
```

### Datasets

Refer to `_data/README.md`.

## Reproduction and Experimentation

### Reproducing our results

We provide scripts to reproduce our work in the `reproducibility_scripts/` directory.
It has a README at its root describing which scripts reproduce which experiments.

### Experiment with different configurations

The default configuration for each script is stored in the `configs/` directory.
They are managed by [Hydra](https://hydra.cc/docs/intro/).
You can experiment with different configurations by passing the relevant flags.
You can get examples of how to do so in the `reproducibility_scripts/` directory.

### Pre-trained models and experiment results

We share our Weights and Biases runs in [this W&B project](fill-me).

## Repository structure

Below, we give a description of the main files and directories in this repository.

```
├── src/ # Source code.
    ├── configs/    # Hydra configuration files.
    └── main.py     # Main entry point.
```

## Contributing

We use [`pre-commit`](https://pre-commit.com) hooks to ensure high code quality.

These should be installed automatically in the development environment and will run before any `git commit` ran
from the environment.
You can also trigger then manually with:

```bash
pre-commit run --all-files
```

Otherwise, when from committing from outside the development environment, make
sure [`pre-commit`](https://pre-commit.com) is installed on
you local system and install the hooks with:

```bash
pre-commit install
```

Then, every time you commit, the hooks will run and check your code.
