> [!IMPORTANT]
> **TEMPLATE TODO:**
> Replace the title below with your project title, then delete this note.

# Python Machine Learning Research Project Template

## Overview

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Replace the description below with a description of your project, then delete this note.

A template for starting Python machine-learning research
projects with hardware acceleration featuring:

- Reproducible environments on major platforms with hardware acceleration with a great development experience
  covering multiple use cases:
    - local machines, e.g., macOS (+ Apple Silicon/MPS) and Linux/Windows WSL (+ NVIDIA GPU).
    - Remote Linux servers with GPUs, e.g., VMs on cloud providers and IC and RCP HaaS at EPFL.
    - Managed clusters supporting OCI containers with GPUs, e.g., the EPFL IC and RCP Run:ai (Kubernetes) clusters.
- Python project packaging following the
  [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/) to avoid hacky
  imports.
- Experiment management, tracking, and sharing with [Hydra](https://hydra.cc/)
  and [Weights & Biases](https://wandb.ai/site).
- Code quality with [pre-commit](https://pre-commit.com) hooks.

The template makes collaboration and open-sourcing straightforward, avoiding setup issues and
[maximizing impact](https://medium.com/paperswithcode/ml-code-completeness-checklist-e9127b168501#a826).
The practices in this template earned its authors
an [Outstanding Paper (Honorable Mention)](https://openreview.net/forum?id=E0qO5dI5aEn)
at the [ML Reproducibility Challenge 2022](https://paperswithcode.com/rc2022).

Projects made with the template would look like
[this toy project](https://github.com/skandermoalla/pytoych-benchmark)
or [this paper](https://github.com/CLAIRE-Labo/no-representation-no-trust) whose curves have been exactly reproduced
(exact same numbers) on multiple different platforms (EPFL Kubernetes cluster, VM on GCP, HPC cluster with Apptainer),

Follow this README to get started with the template.

For a brief discussion of the template's design choices and a Q&A check `template/README.md` file.

## Getting started with the template

> [!IMPORTANT]
> **TEMPLATE TODO:**
> Delete this whole section when you're done with the template getting started.

Click on the `Use this template` GitHub button to create a new GitHub repository from this template.
Give it a lowercase hyphen-separated name (we will refer to this name as `PROJECT_NAME`),
then follow the instructions below to set up your project.
You can also give your GitHub repo another name format if you prefer, but for the template, you will have to pick
a `PROJECT_NAME` as well.

It's useful to commit after some checkpoints to be able to go back if you make a mistake.
Some instructions will send you to different READMEs in the template that will compile nicely together in the end.
Remember to get back to this root one after finishing each step.

1. Clone the repo with destination `PROJECT_NAME`.
    - If you plan to develop on your local computer, clone it there.
    - If you plan to develop on your remote server (with direct access over say SSH, e.g. EPFL HaaS), clone it there.
    - If you plan to develop or deploy on a managed cluster (e.g., EPFL Run:ai clusters), clone on your local machine.
      (Docker allows cross-platform builds with emulation, but it can be slow.
      We would recommend that your local machine is of the same platform as the cluster (e.g. `amd64`, `arm64`),
      or that you have access to a remote Docker engine running on the same platform as the cluster.)
    ```
    git clone <HTTPS/SSH> PROJECT_NAME
    cd PROJECT_NAME
    # The current directory is referred to as PROJECT_ROOT
    ```
   We will refer to the absolute path to the root of the repository as `PROJECT_ROOT`.

2. Fill the template variables in `template/template-variables.env` by
   editing the ones with the `$NEW_` prefix, then run the script
   ```bash
   # After filling the template variables in template/template-variables.env.
   ./template/change-project-name.sh
   ```
   Commit.
3. Initialize the pre-commit hooks as described in the [contributing](#contributing) section.
   Update them to their latest version with `pre-commit autoupdate`.
   Commit.
4. Edit the `LICENSE` file, or delete it and remember to add one when open-sourcing your code.
   [(Some help here).](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   A simple change if you're fine with the MIT license is to replace the `2022 Skander Moalla` with your year and name.
   Commit.
5. Set up and edit the development environment instructions for the methods and platforms you will use and support.
   Each method supports a group of use cases:
    - **Docker**.
      This is the preferred method to run on Linux machines (e.g. EPFL HaaS servers),
      Windows machines with WSL, clusters running OCI-compliant containers like the EPFL Run:ai (Kubernetes) clusters,
      and other cloud services.
      (A tutorial to deploy on Run:ai clusters is provided.)

      The environment is shipped as a Linux Docker image, ensuring the highest level of reproducibility.
      You are free to choose the architecture you want to build the image for,
      e.g. `amd64` or `arm64`.
      By default, this image is set up for `amd64`.
      You are also free to choose the hardware acceleration you want to support.
      By default, this template allows local deployment with NVIDIA GPUs and can extend
      [NGC images](https://catalog.ngc.nvidia.com/containers).

      If you plan to support multiple platforms or hardware accelerations,
      you can duplicate this installation method
      or adapt it to support multiple platforms at the same time.

      Go to `installation/docker-amd64-cuda/README.md` for the setup.
      Come back here after following the instructions there.

      - **Conda**.
        The environment is shipped as a conda environment file.
        The level of reproducibility is lower than with Docker, as system dependencies will not be strictly recorded.
        The only reason this option is available is to leverage hardware acceleration of platforms not compatible with
        OCI containers, in particular, [MPS](https://developer.apple.com/metal/pytorch/)
        which is [not supported](https://github.com/pytorch/pytorch/issues/81224)
        on Docker for macOS with Apple Silicon.

        By default, this option is set up for `osx-arm64` to run on macOS with Apple Silicon.
        This installation method could also be used if you want to settle for a lower level of reproducibility
        and do not need to run on container clusters.
        In that case, you might support another platform, e.g. `amd64`, and hardware acceleration, e.g., NVIDIA GPUs.

        If you plan to support multiple platforms or hardware accelerations,
        you can duplicate this installation method
        or adapt it to support multiple platforms at the same time.

        Go to `installation/conda-osx-arm64-mps/README.md` for the setup.
        Come back here after following the instructions there.

   Delete the installation directory for the installation method you don't use.

   Naturally, results will be reproducible on machines with the same architecture and hardware acceleration
   using the same installation method,
   but not necessarily across architectures and installation methods.
   This is because dependency versions may vary across platforms.
   Try to keep the dependency versions close to ensure an easy replicability of your results.

6. Edit this `README.md` file.
    1. Edit the title with the name of your project.
       Replace the [Overview](#overview) section with a description of your project.
    2. Delete the installation options you don't support in
       the [Getting Started](#getting-started) section.
    3. Have a look at the last paragraph below describing how to keep your project in good shape,
       then delete this getting started, to only keep the project [Getting Started](#getting-started) section.

You're off to a good start! If you made it here, give the template a star!
Here are a few tips for keeping your project in good shape.

- Keep this README up to date.
  Fill in the rest of the sections after the Getting Started section when releasing your project.
  We give a structure and some templates for those.

  If you use datasets, follow `data/README.md` to set them and write the instructions
  for the subsequent users there.
  Otherwise, delete the [data](#data) section.

  Similarly, you can use the `outputs/README.md` file to share your trained models, logs, etc.
- Remember to pin your dependencies whenever you install new ones.
  This is well described in the Maintaining the environment section of the installation instructions.
- Keep your `reproducibility-scripts/` directory up to date.
  Commit it regularly and run your jobs with those scripts.
  More on this in the [reproducibility](#reproducing-our-results) section.
- Maintain good commit hooks. More on this in the [Contributing](#contributing) section.
- Have a look at the [ML Code Completeness Checklist](https://github.com/paperswithcode/releasing-research-code).
  This template facilitates meeting all the checklist items, with a different design.
  Have a look at the checklist when you ship your project.

## Getting started

### Code and development environment

> [!IMPORTANT]
> **TEMPLATE TODO**:
> Update the installation methods and platforms you support, delete the rest, and delete this note.
> I.e. keep either Docker or Conda, or both, or multiple of each if you support multiple platforms.
> 1. Specify the platform for each option and its description
>    e.g., for Docker amd64, arm64, etc., and for conda osx-arm64, linux-amd64, etc.
> 2. Specify the hardware acceleration options for each platform
>    e.g., for Docker NVIDIA GPUs, AMD GPUs etc.
> 3. Specify the hardware on which you ran your experiments (e.g., type of CPU/GPU and size of memory) and
>    the minimum hardware required to run your code if applicable (e.g., NVIDIA GPU with 80GB of memory).

We support the following methods and platforms for installing the project dependencies and running the code.

- **Docker/OCI-container for AMD64 machines (+ NVIDIA GPUs)**:
  This option works for machines with AMD64 CPUs and NVIDIA GPUs.
  E.g. Linux machines (EPFL HaaS servers, VMs on cloud providers),
  Windows machines with WSL, and clusters running OCI-compliant containers,
  like the EPFL Run:ai (Kubernetes) clusters.

  Follow the instructions in `installation/docker-amd64-cuda/README.md` to install the environment
  then get back here for the rest of the instructions to run the experiments.

  We ran our experiments on TODO: FILL IN THE HARDWARE YOU USED.
  To run them, you should have at least TODO: FILL IN THE MINIMUM HARDWARE REQS IF APPLICABLE.

- **Conda for osx-arm64**
  This option works for macOS machines with Apple Silicon and can leverage MPS acceleration.

  Follow the instructions in `installation/conda-osx-arm64-mps/README.md` to install the environment
  then get back here for the rest of the instructions to run the experiments.

  We ran our experiments on TODO: FILL IN THE HARDWARE YOU USED.
  To run them, you should have at least TODO: FILL IN THE MINIMUM HARDWARE REQS IF APPLICABLE.

### Data

> [!IMPORTANT]
> **TEMPLATE TODO**:
> Fill `data/README.md` or delete this section, then delete this note.

Refer to `data/README.md`.

### Logging and tracking experiments

We use [Weights & Biases](https://wandb.ai/site) to log and track our experiments.
If you're logged in, your default entity will be used (a fixed entity is not set in the config),
and you can set another entity with the `WANDB_ENTITY` environment variable.
Otherwise, the runs will be anonymous (you don't need to be logged in).

## Reproduction and experimentation

### Reproducing our results

> [!IMPORTANT]
> **TEMPLATE TODO**:
> Keep these scripts up to date and run your experiments using them.
> Do provide the W&B runs and trained models or update this section.
> Delete this note when shipping.

We provide scripts to reproduce our work in the `reproducibility-scripts/` directory.
It has a README at its root describing which scripts reproduce which experiments.

We share our Weights and Biases runs in [this W&B project](https://wandb.ai/claire-labo/template-project-name).

Moreover, we make our trained models available.
You can follow the instructions in `outputs/README.md` to download and use them.

### Experiment with different configurations

The default configuration for each script is stored in the `configs/` directory.
They are managed by [Hydra](https://hydra.cc/docs/intro/).
You can experiment with different configurations by passing the relevant arguments.
You can get examples of how to do so in the `reproducibility-scripts/` directory.

## Repository structure

> [!IMPORTANT]
> **TEMPLATE TODO**:
> Provide a quick overview of the main files in the repo for users to understand your code,
> then delete this note.

Below, we give a description of the main files and directories in this repository.

```
 └─── src/                              # Source code.
    └── template_package_name           # Our package.
        ├── configs/                    # Hydra configuration files.
        └── template_experiment.py      # A template experiment.
```

## Contributing

We use [`pre-commit`](https://pre-commit.com) hooks to ensure high-quality code.
Make sure it's installed on the system where you're developing
(it is in the dependencies of the project, but you may be editing the code from outside the development environment.
If you have conda you can install it in your base environment, otherwise, you can install it with `brew`).
Install the pre-commit hooks with

```bash
# When in the PROJECT_ROOT.
pre-commit install --install-hooks
```

Then every time you commit, the pre-commit hooks will be triggered.
You can also trigger them manually with:

```bash
pre-commit run --all-files
```

## Licenses and acknowledgements

This project is licensed under the LICENSE file in the root directory of the project.

The initial code of this repository has been initiated by the [Python Machine Learning Research Project Template](https://github.com/CLAIRE-Labo/python-ml-research-template)
with the LICENSE.ml-template file.

Additional LICENSE files may be present in subdirectories of the project.
