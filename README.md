# Python Machine Learning Research Project Template

## Overview

This is a template used for starting Python machine-learning research
projects with hardware acceleration at the EPFL CLAIRe (tentative name) lab.
It features and encourages best practices for:

- Reproducible environments on major platforms with hardware acceleration (x86-64/AMD64 + Docker-supporting OS + NVIDIA GPU and macOS + Apple Silicon)
  with a great user and development experience covering multiple use cases, including:
    - Your local machine, e.g. macOS + Apple Silicon or Intel CPU, Windows with WSL or Linux + GPU,
    - Remote servers with GPUs, e.g. VMs on cloud providers, HaaS from EPFL IC,
    - Managed platforms GPUs, e.g. the EPFL IC RunAI Kubernetes cluster (and soon other public cloud services like GCP Vertex AI, AWS SageMaker, ...).
- Experiment management, tracking, and sharing with [Hydra](https://hydra.cc/)
  and [Weights & Biases](https://wandb.ai/site).
- Python project packaging following the
  [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- Code quality with [pre-commit](https://pre-commit.com) hooks.

Thanks to its focus on reproducibility, this template can readily be used by other labs at EPFL and beyond.
With this template, sharing your work will be a breeze, and its adoption will be straightforward,
[maximizing its impact](https://medium.com/paperswithcode/ml-code-completeness-checklist-e9127b168501).
The practices in this template earned its authors
an [Outstanding Paper (Honorable Mention)](https://openreview.net/forum?id=E0qO5dI5aEn) at the
[ML Reproducibility Challenge 2022](https://paperswithcode.com/rc2022).

The template can also be adapted to suit many other use cases, however, its maintained form will be tailored to the
needs of CLAIRe.
It also contains extra EPFL-specific instructions for deployment on the EPFL RunAI Kubernetes cluster.
For more information on the template and a discussion of its design choices see the `template/README.md` file.

## Getting started with the template

Click on the `Use this template` GitHub button to create a new GitHub repository from this template.
Give it a lowercase hyphen-separated name (we will refer to this name as `PROJECT_NAME`),
then follow the instructions below to set up your project.
You can also give your repo another name format if you prefer, but for the template you will have to pick a `PROJECT_NAME` as well.
It's useful to commit after some checkpoints to be able to go back if you make a mistake.

1. Clone the repo as the `PROJECT_NAME`.
   - If you plan to develop on your local computer, clone it there.
   - If you plan to develop on your remote server (with direct access over say SSH, e.g. EPFL HaaS), clone it there.
   - If you plan to develop or deploy on a managed cluster (e.g. EPFL IC RunAI cluster), clone on you local machine, or ideally an AMD64 platform.
  ```
  git clone <URL/SSH> PROJECT_NAME
  ```
3. Fill the template variables in `template/template_variables.env` and run the script
   ```bash
   ./template/fill_template.sh
   ```
   Then delete the `template` directory and commit.
4. Edit the `LICENCE` file.
   Or delete it and remember to add one when open-sourcing your code.
   [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT license is to replace the `2022 Skander Moalla` with your year and name.
   Commit.
5. Set up and edit the development environment instructions for the platforms you will use and support.
   Each platform group supports specific of use cases:
    - **AMD64 (x86-64) platforms supporting Docker** to run on Linux machines (e.g. EPFL HaaS servers), Windows laptops with WSL,
      macOS with Intel CPU, Kubernetes clusters like the EPFL RunAI cluster, and other cloud services. With support for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`.
    - **macOS with Apple Silicon (`osx-arm64`)** to run on native Apple Silicon and for the MPS (Apple Silicon) hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.
   Naturally, results will be reproducible on machines within the same platform group, but not necessarily accross platform groups.
   This is because dependecy versions may vary accross platforms and hardware acceleration may behave differently.
   Try to keep the dependency versions as close as possible to ensure the replicability of your results. 

   Delete the installation directory for the platforms you don't use.

   In addition, it is good to list your direct dependencies (with major versions when relevant)
   for users with other needs.
   This is described in the next instructions in the [development environment](#development-environment) section.
6. Edit this `README.md` file.
    1. Edit the title with the name of your project.
       Replace the [Overview](#overview) section with a description of your project.
    2. Delete the installation options you don't support in
       the [Getting Started](#getting-started) section.
    3. List your direct dependencies (with major versions when relevant)
       in the [Getting Started](#getting-started) section.
    4. If you use datasets, describe how to obtain them in the [datasets](#datasets) section.
       You can refer the users to `_data/README.md` and write the instructions there.
       The template has a common directory structure across all installation methods.
       So you should ask the users to put or create symlinks to the data somewhere in the `data/` directory.
       (More info on the directory structure in the `template/README.md` file.).
       ```
       PROJECT_ROOT/        # The root of the project can be any name.
       ├── template-project-name/  # The root of the the git repository.
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

- **AMD64 (x86-64) platforms supporting Docker** to run on Linux machines (e.g. EPFL HaaS servers), Windows laptops with WSL,
  macOS with Intel CPU, Kubernetes clusters like the EPFL RunAI cluster, and other cloud services. With support for NVIDIA GPUs.
  Refer to `installation/docker-amd64/README.md`.
- **macOS with Apple Silicon (`osx-arm64`)** to run on native Apple Silicon and for the MPS (Apple Silicon) hardware acceleration.
  Refer to `installation/osx-arm64/README.md`.

We list below our direct dependencies (with major versions when relevant) for users with other needs.

```text
Python 3.10

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
Make sure it's installed on the system where you're developing
(it is in the dependencies of the project, but you may be editing the code from outside the development environment).
Install the pre-commit hooks with

```
# When in the PROJECT_DIR directory.
pre-commit install
```

You can also trigger them manually with:

```bash
pre-commit run --all-files
```
