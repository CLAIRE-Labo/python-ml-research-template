# python-package-template

## [_DELETE ME_] Template Info

A template for starting a new Python project, inspired from the
[PyPA packaging tutorial](https://packaging.python.org/en/latest/tutorials/packaging-projects/).
It contains the minimal files needed to start a project with good practices.

Feel free to `Use this template` (GitHub button) and

1. Fill the template variables in `template/template_variables.sh` and run the script
   ```bash
   source template/fill_template.sh
   ```
   Then, delete the `template` directory.
2. Edit the `LICENCE`
   file. [(Some help here.)](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
3. Setup and edit the development environment instructions for the platforms you'll use/support.
   We support 1 platform for now:
    - macOS with Apple Silicon (`osx-arm64`): refer to `installation/osx-arm64/README.md`.

   Delete the _Template info_ section in the installation instructions of the platforms you plan to support, and the
   whole installation directory for the platforms you don't use.
4. Edit this `README.md` file.
    1. Add a description of your project in the [_Overview_](#overview) section.
    2. Delete the [installation instructions](#development-environment) for the platforms you don't support.
    3. Delete this section.

## Overview

[_EDIT ME_] Description of your project.

## Getting Started

### Development environment

We support the following platforms for installing the project dependencies and running the code.

* macOS with Apple Silicon (`osx-arm64`); using a [Conda](https://docs.conda.io/en/latest/) environment.
    - Refer to `installation/osx-arm64/README.md`.
