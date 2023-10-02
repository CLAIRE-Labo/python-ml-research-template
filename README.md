# Python Machine Learning Research Project Template

## Overview

This is a template used for starting Python machine-learning research
projects with hardware acceleration at the EPFL CLAIRE lab.
It features and encourages best practices for:

- Reproducible environments on major platforms with hardware acceleration (x86-64/AMD64 + Docker-supporting OS + NVIDIA
  GPU and macOS + Apple Silicon)
  with a great user and development experience covering multiple use cases, including:
    - Your local machine, e.g. macOS + Apple Silicon or Intel CPU, Windows with WSL or Linux + GPU.
    - Remote servers with GPUs, e.g. VMs on cloud providers, HaaS from EPFL IC.
    - Managed platforms with GPUs, e.g. the EPFL IC RunAI Kubernetes cluster.
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
needs of CLAIRE.
It also contains extra EPFL-specific instructions for deployment on the EPFL RunAI Kubernetes cluster.
For more information on the template and a discussion of its design choices see the `template/README.md` file.

> 📘 [TEMPLATE] EDIT ME:
> Replace the above with a description of your project, then delete this note.

> [!NOTE]
> Each step has it's own virtual environment and requirements.txt file to accommodate the requirements of each step.

> [!WARN]
> Each step has it's own virtual environment and requirements.txt file to accommodate the requirements of each step.


## Getting started with the template

Click on the `Use this template` GitHub button to create a new GitHub repository from this template.
Give it a lowercase hyphen-separated name (we will refer to this name as `PROJECT_NAME`),
then follow the instructions below to set up your project.
You can also give your repo another name format if you prefer, but for the template you will have to pick
a `PROJECT_NAME` as well.
It's useful to commit after some checkpoints to be able to go back if you make a mistake.

1. Clone the repo with destination `PROJECT_NAME`.
   ```
   git clone <URL/SSH> PROJECT_NAME
   ```
    - If you plan to develop on your local computer, clone it there.
    - If you plan to develop on your remote server (with direct access over say SSH, e.g. EPFL HaaS), clone it there.
    - If you plan to develop or deploy on a managed cluster (e.g. EPFL IC RunAI cluster), clone on you local machine,
      and ideally an AMD64 platform.

2. Fill the template variables in `template/template_variables.env` and run the script
   ```bash
   template/fill_template.sh
   ```
   Then delete the `template` directory and commit.
3. Edit the `LICENCE` file.
   Or delete it and remember to add one when open-sourcing your code.
   [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT license is to replace the `2022 Skander Moalla` with your year and name.
   Commit.
4. Set up and edit the development environment instructions for the platforms you will use and support.
   Each platform group supports specific use cases:
    - **AMD64 (x86-64) platforms supporting Docker** to run on Linux machines (e.g. EPFL HaaS servers),
      Windows laptops with WSL, macOS with Intel CPU, Kubernetes clusters like the EPFL RunAI cluster,
      and other cloud services. With support for NVIDIA GPUs.

      Refer to `installation/docker-amd64/README.md`.

      This is shipped as a Docker image ensuring the highest level of reproducibility.
    - **macOS with Apple Silicon (`osx-arm64`)** to run on native Apple Silicon
      with support for the MPS (Apple Silicon) hardware acceleration.

      Refer to `installation/osx-arm64/README.md`.

      The level of reproducibility is lower than with Docker, as system dependencies will not be strictly recorded.

   Naturally, results will be reproducible on machines within the same platform group, but not necessarily across
   platform groups.
   This is because dependency versions may vary across platforms and hardware acceleration may behave differently.
   Try to keep the dependency versions as close as possible to ensure the replicability of your results.

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
    4. Have a look at the last paragraph below describing how to keep your project in good shape,
       then delete this getting started, to only keep the project [Getting Started](#getting-started) section.

You're off to a good start! Here are a few tips for keeping your project in good shape.

- Keep this README up to date.
  Fill in the rest of the sections after the Getting Started when releasing your project.
  We give a structure and some templates for those.

  If you use datasets, follow `_data/README.md` to set them and write the instructions
  for the subsequent users there.
  Otherwise, delete the [datasets](#datasets) section.
- Remember to pin your dependencies whenever you install new ones.
  This is well described in the Maintaining the environment section of the installation instructions.
- Keep your `reproducibility_scripts/` directory up to date.
  Commit it regularly and run your jobs with those scripts.
  More on this in the [Reproducibility](#reproducibility) section.
- Maintain good commit hooks. More on this in the [Contributing](#contributing) section.
- Have a look at the [ML Code Completeness Checklist](https://github.com/paperswithcode/releasing-research-code).
  This template facilitates meeting all the checklist items, with a different design.
  Have a look at the checklist when you will ship your project.

> [TEMPLATE] DELETE ME:
> Delete this whole section when you're done with the template getting started.

## Getting Started

### Code and development environment

We support the following platforms for installing the project dependencies and running the code.

- **AMD64 (x86-64) platforms supporting Docker** to run on Linux machines (e.g. EPFL HaaS servers),
  Windows laptops with WSL, macOS with Intel CPU, Kubernetes clusters like the EPFL RunAI cluster,
  and other cloud services. With support for NVIDIA GPUs.

  Refer to `installation/docker-amd64/README.md`.
- **macOS with Apple Silicon (`osx-arm64`)** to run on native Apple Silicon and
  for the MPS (Apple Silicon) hardware acceleration.

  Refer to `installation/osx-arm64/README.md`.

We list below our direct dependencies (with major versions when relevant) for users with other needs.

```text
Python 3.10

Python packages:
wandb
hydra
tqdm
```

> [TEMPLATE] UPDATE ME:
> Update the above with your direct dependencies before shipping your project, then delete this note.

### Data

Refer to `_data/README.md`.

> [TEMPLATE] UPDATE ME:
> Fill `_data/README.md` or delete this section, then delete this note.

## Reproduction and Experimentation

### Reproducing our results

We provide scripts to reproduce our work in the `reproducibility_scripts/` directory.
It has a README at its root describing which scripts reproduce which experiments.

### Experiment with different configurations

The default configuration for each script is stored in the `configs/` directory.
They are managed by [Hydra](https://hydra.cc/docs/intro/).
You can experiment with different configurations by passing the relevant arguments.
You can get examples of how to do so in the `reproducibility_scripts/` directory.

### Trained models and experiment with results

We share our Weights and Biases runs in [this W&B project](fill-me).

Moreover, we make our trained models available.
You can follow the instructions in `_outputs/README.md` to download and use them.

> [TEMPLATE] UPDATE ME:
> Do provide the runs and trained models or update/delete this section, then delete this note.

## Repository structure

Below, we give a description of the main files and directories in this repository.

```
├── src/ # Source code.
    ├── configs/    # Hydra configuration files.
    └── main.py     # Main entry point.
```

> [TEMPLATE] UPDATE ME:
> Provide a quick overview of the main files in the repo for users to experiment with your code,
> then delete this note.

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
