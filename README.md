# Python Machine Learning Research Project Template

## Overview

This is a template used for starting python machine learning research
projects with hardware acceleration at the EPFL CLAIRe (tentative name) lab.
It features and encourages good practices for:

- Reproducible environments that can be used/deployed on multiple platforms with hardware acceleration.
  E.g. local computers (macOS + Apple Silicon, WSL + GPU), linux servers (like HaaS at EPFL),
  the EPFL IC RunAI Kubernetes cluster.
- Experiment management, tracking, and sharing with [Weights & Biases](https://wandb.ai/site)
  and [Hydra](https://hydra.cc/).
- Python project packaging following the
  [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- Code quality with [pre-commit](https://pre-commit.com) hooks.

With this template, sharing your work will be a breeze, and its adoption will be straightforward,
maximizing its impact.
The practices in this template earned its authors an Outstanding Paper (Honorable Mention) at the
ML Reproducibility Challenge 2022. (TODO, link to paper)

Thanks to its focus on reproducibility, this template can readily be used by other labs at EPFL and beyond.
It can also be adapted to suit many other use cases.
However, it's maintained form will be tailored to the needs of CLAIRe (tentative name).
It also contains extra EPFL-specific instructions for deployment on the RunAI Kubernetes cluster.

## Getting started with the template

Click on the `Use this template` GitHub button to create a new GitHub repository from this template.
Give it a hyphen-separated name, then follow the instructions below to set up your project.

1. Clone the repo.
2. Fill the template variables in `template/template_variables.sh` and run the script
   ```bash
   ./template/fill_template.sh
   ```
   Then, delete the `template` directory.
   Read the [contributing section](#contributing) and commit.
3. Edit the `LICENCE` file.
   Or delete it and remember to add one when open-sourcing your code.
   [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT licence is to replace the `2022 Skander Moalla` with your year and name.
   Commit.
4. Setup and edit the development environment instructions for the platforms you'll use/support.
   We support the following platforms:
    - **AMD64 platforms (x86-64)** (e.g. linux server like the EPFL HaaS servers, WSL on a local machine, Kubernetes
      clusters like the EPFL RunAI cluster), with support for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`.
    - **macOS with Apple Silicon (`osx-arm64`)**, with support for MPS hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.

   Delete the directory for the platforms you don't use.

   In addition, it is good to list your direct dependencies (with major versions when relevant)
   for users with other needs.
   This is described in the next instructions.
5. Edit this `README.md` file.
    1. Edit the title with the name of your project.
       Replace the [_Overview_](#overview) section a the description of your project.
    2. Delete the installation options you don't support in
       the [Getting Started](#getting-started) section.
    3. List your direct dependencies (with major versions when relevant)
       in the [Getting Started](#getting-started) section.
    4. If you use datasets, describe how to obtain them in the [datasets](#datasets) section.
       You can refer the users to `_data/README.md` and write the instructions there.
       The template has a common directory structure across all installation methods.
       So you should ask the users to put the data somewhere in the `data/` directory.
       ```
       PROJECT_ROOT/        # The root of the project can be any name.
       ├── <project-name>/  # The root of the the git repository.
       ├── data/            # This is from where the data will be read (will mount/symlink to somewhere by the user).
       ├── outputs/         # This is where the outputs will be written (will mount/symlink to somewhere by the user).
       ```
       Otherwise, delete the section.
    5. Delete this getting started, to only keep the project [Getting Started](#getting-started) section.

You're off to a good start! Here are a few tips for keeping your project in a good shape.

- Keep this README up to date.
  Fill the sections after the Getting Started when releasing your project.
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

* **AMD64 platforms (x86-64)** (e.g. linux server like the EPFL HaaS servers, WSL on a local machine, Kubernetes
  platforms like the EPFL RunAI Platform), with support for NVIDIA GPUs.
  Refer to `installation/docker-amd64/README.md`.
* **macOS with Apple Silicon (`osx-arm64`)**, with support for MPS hardware acceleration.
  Refer to `installation/osx-arm64/README.md`.

We list below our direct dependencies (with major versions when relevant) for users with other needs.

```bash
Python:
wandb - https://github.com/wandb/wandb/
hydra - https://github.com/facebookresearch/hydra
tqdm  - https://github.com/tqdm/
```

### Datasets

Refer to `_data/README.md`.

## Reproduction and Experimentation

### Reproducing our results

We provide scripts to reproduce our work in the `reproducibility_scripts/` directory.
It has a README at its root describing which scripts reproduce which experiments.

### Experiment with different configurations

The default configuration for each experiment are stored in the `configs/` directory.
They are managed by [Hydra](https://hydra.cc/docs/intro/).
You can experiment with different configurations by passing the relevant flags.
You can get examples on how to do so in the `reproducibility_scripts/` directory.

### Pre-trained models and experiment results

We share our Weights and Biases runs in [this anonymized W&B project]().

## Repository structure

Below, we give a description of main files and directories in this repository.

```
├── src/ # Source code.
    ├── configs/    # Hydra configuration files.
    └── main.py     # Main entry point.
```

## Contributing

We use [pre-commit](https://pre-commit.com) hooks to ensure code quality.
Make sure it's installed on your system.
Refer to the installation instructions in the [development environment](#development-environment)
section for your platform.

As a first step, install the pre-commit hooks with

```bash
pre-commit install
```

Then, every time you commit, the hooks will run and check your code.
