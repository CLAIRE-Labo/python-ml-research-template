# Additional Details about the Template

## Reproducibility

This template ensures the reproducibility of your results through 3 artifacts:

1. The development environment
    - Recorded in the Docker images that you upload and described in Dockerfile and environment files
      that you keep up to date with the Docker installation.
    - (Less reliably) described in the environment file that you keep up to date for the conda installation.
2. The project code.
    - Recorded in the git repository that you keep up to date.
    - Made reproducible (to a desired degree) by you correctly seeding the random number generators and
      optionally removing non-deterministic operations or replicable by running enough seeds.
3. The data, outputs, model weights and other artifacts.
    - Recorded and uploaded by you.
    - (Virtually) placed in the placeholder directories abstracting away the user storage system.

## Template Q&A

### I started my project from an older version of the template, how do I get updates?

A project started from a template is different from a fork in that it is not (necessarily) meant to be updated.
The template is free to change and evolve, and it is not guaranteed that it will be compatible with your project.

Nevertheless, many changes are likely to be compatible with your project.
In that case, there are two ways to incorporate them:

1. Manually copy the changes from the template to your project, adapting them when needed (different variable names especially).
2. Use git to merge the changes from the template to your project.
```bash
git remote add template https://github.com/CLAIRE-Labo/python-ml-research-template.git
git fetch template
# Cherry pick the commits you want to merge, making sure they are compatible.
# Add the option -n if you want to have the changes staged but not committed so you can edit them.
git cherry-pick -x <commit-hash>
```

### Why Docker? Why not just Conda? (At least for container-compatible hardware acceleration methods.)

Conda environments are not so self-contained, some packages can just work on your machine because
they use some of your system libraries not recorded in the conda environment.
An exhaustive and precise list of the system libraries outside conda is hard to record,
and the environment will not run on another machine missing those libraries.
Reinforcement learning (RL) environments usually require system libraries
not recorded by conda, and RL is a big part of our work.

Moreover, the environment is specified as an `environment.yml` file description,
and does not contain the dependencies themselves.
Some dependencies may actually become unavailable when a user tries to download them later.

Docker images are self-contained and do contain the dependencies themselves.

### Why is the template so complex, e.g., include so many files?

Some reasons for many files and extra code is to be able to provide a generic template
that can be configured, extended, or shortened depending on the needs of the project.

The other part of the apparent complexity probably comes from unfamiliarity with the tools and practices
used in the template.
These practices, however, (although usually not all combined in a research project, whence this template)
are well established and have been proven to be very useful.

For example, the `Dockerfile` seems complex because it leverages multi-staging to be very
time and cache-efficient.
Different build stages can run in parallel, so changing your build dependencies,
or installing something in the Dockerfile will cause very few rebuilds.

Using Docker Compose is also very convenient to define all the build arguments and multiple deployment options
in a single file, avoiding long build and run commands.

### Why does the template have so many tools by default (e.g. `hydra`, `wandb`, `black`, etc.)?

This template is mainly addressed to students and researchers at CLAIRE.
Frequently, students are not aware of the tools and practices that are available to them until they face the problems
we've all faced at some point in our career
(how do I manage my configs? How do conveniently log my metrics?, etc.).
We chose to include these tools by default to help students and researchers avoid these problems from the start,
and to encourage them to use them.

### Can I fork a project that used the template and change its name? How do I do that?

Yes, it seems like filling the `template/template-variables.env` file with your new project name and
running `./template/change-project-name.sh` would work.

### Can I use this template for an already existing project? How do I do that?

The template is mainly designed to start new projects, as it's hard to make assumptions on
the structure of an existing project.
However, it is possible to use it to transfer from an existing project.

It's likely that your project is a bunch of Python files and a `requirements.txt` or `environment.yml` file.
You can copy those files and potentially refactor the package structures and put all of them under `src`.
You will also have to transfer the dependencies to the `environment.yml` file and identify the system dependencies.

If your project provides a Docker image, the Docker installation method allows extending it, assuming
it has a well-configured Python environment.

In the worst case, you can keep the `installation/` directory if that's useful to you and replace all the rest with
your project and adapt the installation as needed.
You could also just get some inspiration from the template and do your own thing.
