# lab_name-project-template

## Overview

_[EDIT ME. A description of your project.]_

This repo is template for starting python research projects at the <lab-name> lab with hardware acceleration.
It features and encourages good practices for:

- Reproducible environments that can be used/deployed on multiple platforms with hardware acceleration.
  E.g. your local computer (macOS, WSL), the lab server (HaaS), the RunAI Kubernetes platform,
  and (most importantly) someone else's server or local computer.
  That is, the instructions to install the environment assume users outside the lab.
- Experiment management, tracking, and sharing with `wandb` and `hydra`.
- Python project packaging inspired from
  the [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- TODO. Code quality and style with `flake8` and `black`.

Because of its focus on reproducibility, this template can readily be used by other labs et EPFL and beyond.
It can also be adapted to suit many other use cases.
However, it's maintained form will be tailored to the needs of the <lab-name> lab.
It also contains extra EPFL-specific instructions for deployment on the RunAI Kubernetes platform.

## Getting started with the template

[DELETE ME. Delete this section afterwards, and keep the "Getting started" below.]

Feel free to `Use this template` (GitHub button) and

1. Fill the template variables in `template/template_variables.sh` and run the script
   ```bash
   source template/fill_template.sh
   ```
   Then, delete the `template` directory.
2. Edit the `LICENCE`
   file. [(Some help here.)](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
3. Setup and edit the development environment instructions for the platforms you'll use/support.
   We support the following platforms:
    - **macOS with Apple Silicon (`osx-arm64`)**, with support for MPS hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.
    - **Docker on AMD64 platforms** (e.g. linux server like the EPFL HaaS servers, WSL on you local machine, Kubernetes
      platforms like the EPFL runai Platform), with support for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`
      Delete the _Template info_ section in the installation instructions of the platforms you plan to support, and the
      whole installation directory for the platforms you don't use.
4. Edit this `README.md` file.
    1. Replace the [_Overview_](#overview) section with description of your project.
    2. Delete the [installation instructions](#development-environment) for the platforms you don't support.
    3. Delete this section [(Getting started with the template)](#getting-started-with-the-template).

## Template FAQ

### Can I use this template for an already existing project? How do I do that?


## Getting Started

TODO. This will be the public getting started.

### Development environment

We support the following platforms for installing the project dependencies and running the code.

* macOS with Apple Silicon (`osx-arm64`); using a [Conda](https://docs.conda.io/en/latest/) environment.
    - Refer to `installation/osx-arm64/README.md`.