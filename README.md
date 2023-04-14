# MLO Project Template

## Overview

This repo is template for starting python research projects at the EPFL MLO lab with hardware acceleration.
It features and encourages good practices for:

- Reproducible environments that can be used/deployed on multiple platforms with hardware acceleration.
  E.g. your local computer (macOS, WSL), the lab server (HaaS), the RunAI Kubernetes platform,
  and (most importantly) someone else's server or local computer.
  That is, the instructions to install the environment assume users outside the lab.
- Experiment management, tracking, and sharing with `wandb` and `hydra`.
- Python project packaging inspired from
  the [PyPA packaging guidelines](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
- TODO. Code quality and style with `flake8` and `black`.

With this, open-sourcing your code and project will be a breeze.

Because of its focus on reproducibility, this template can readily be used by other labs et EPFL and beyond.
It can also be adapted to suit many other use cases.
However, it's maintained form will be tailored to the needs of the MLO lab.
It also contains extra EPFL-specific instructions for deployment on the RunAI Kubernetes platform.

## Getting started with the template

Click on the `Use this template` (GitHub button) to create a new repo, clone it, and

1. Fill the template variables in `template/template_variables.sh` and run the script
   ```bash
   . template/fill_template.sh
   ```
   Then, delete the `template` directory.
2. Edit the `LICENCE`
   file. [(Some help here.)](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
   TODO: give a minimal change that will make the licence valid. like just changing the name of the author.
3. Setup and edit the development environment instructions for the platforms you'll use/support.
   We support the following platforms:
    - **macOS with Apple Silicon (`osx-arm64`)**, with support for MPS hardware acceleration.
      Refer to `installation/osx-arm64/README.md`.
    - **Docker on AMD64 platforms** (e.g. linux server like the EPFL HaaS servers, WSL on you local machine, Kubernetes
      platforms like the EPFL RunAI Platform), with support for NVIDIA GPUs.
      Refer to `installation/docker-amd64/README.md`.

   Delete the _Template info_ section in the installation instructions of the platforms you plan to support, and the
   whole installation directory for the platforms you don't use.

   In addition, it is good to list your direct dependencies (with versions when relevant) for users with other needs.
   Edit the section `Dependencies` as described below.
4. Edit this `README.md` file.
    1. Replace the [_Overview_](#overview) section with description of your project.
    2. Delete the [installation instructions](#development-environment) for the platforms you don't support.
    3. List your direct dependencies (with versions when relevant) in the Dependencies section. (Todo: link.)
    4. Delete this getting started and the Template FAQ sections, to only keep the project [Getting Started](#getting-started)
       section.
5. You're off to a good start! Here are a few tips for keeping your project in a good shape.
    - Todo.

## Template FAQ

### Can I use this template for an already existing project? How do I do that?

### Why Docker? Why not just Conda?

1. Conda environments are not so self-contained, some packages can just work on your machine because they use some of
   your system libraries.
2. Reinforcement learning (RL) environments usually require system libraries not available in Conda
   and RL is a big part of our work.
3. It is not trivial to port Conda environments across platforms.

Docker is a good solution to these problems.

### Why is the template so complex?

It probably seems complex at first sight because you are not familiar with the tools and practices it uses.
However, these practices (probably not usually combined in a research project, whence this template) are
well established and have been proven to be very useful.

For example the `Dockerfile` seems complex because it leverages multi-staging to be very
cache-efficient.
Changing your build dependencies, or installing something in the Dockerfile will cause very little rebuilds.

### Why is the template so big?

Same as above, but we're happy to get your feedback on how to make it smaller.

### Why does the template use so many tools by default (e.g. `hydra`, `wandb`, `black`, etc.)?

This template is mainly addressed to students and researchers at the <lab-name> lab.
Frequently students are not aware of the tools and practices that are available to them, until they face the problems
we've all faced at some point in our career.
We chose to include these tools by default to help students and researchers avoid these problems from the start,
and to encourage them to use them.

## Getting Started

TODO. This will be the public getting started.

### Development environment

Todo. This will be the public instructions.

We support the following platforms for installing the project dependencies and running the code.

* macOS with Apple Silicon (`osx-arm64`); using a [Conda](https://docs.conda.io/en/latest/) environment.
    - Refer to `installation/osx-arm64/README.md`.