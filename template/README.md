# Additional Details about the Template

## Directory structure

The python entrypoint of the template assumes a common directory structure across all installation methods.
It is the following:

```text
PROJECT_ROOT/        # The root of the project (opt/project on the AMD64 setup and template-project-name on the macOS setup).
├── template-project-name/  # The root of the git repository.
├── data/            # This is from where the data will be read.
├── outputs/         # This is where the outputs will be written.
└── wandb/           # This is where wandb artifacts will be written.
```

The structure does not force you to put all the directories on the same filesystem, instead the instructions will tell
you to create these directories as symlinks to anywhere else you wish.

The point of this structure is to keep the python code agnostic of the installation method and platform.
In particular the hydra configuration files will be the same across platforms and installation methods.
We could also have used environment variables to specify the paths, but we find them not as convenient to use as
we cannot set them automatically for you depending on the platform, especially local machines,
which means you have to remember to set them every time.
Furthermore, we want to keep the template as contained as possible, which means not altering the user's global
environment.
We thus prefer to have a longer configuration step at the beginning, that may differ on the platform and add some
boilerplate code, but then have a seamless experience.

## Template FAQ

### Can I use this template for an already existing project? How do I do that?

TODO. Future work.

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
time and cache-efficient.
Different build stages can run in parallel and changing your build dependencies,
or installing something in the Dockerfile will cause very little rebuilds.

It is worth noting that the authors of this template have received an outstanding mention at MLRC2022 (TODO. link) using
the practices and tools in this template.

### What's the difference between this template and [Cresset](https://github.com/cresset-template/cresset)?

Cresset and this template share the same goals and philosophy.
However, they differ in implementation details and their target audience.
Cresset has started as a template for building PyTorch from source in Docker images and for offering multiple build
customization.
From there, it has evolved to include non PyTorch-specific deployment options and may continue to change in the future.

This template is heavily inspired by Cresset in its build system and its philosophy, however it extends it to include
a default python project structure, a default set of tools and practices, and a default workflow.

The authors of this template have used Cresset in the past and have collaborated with its authors.

### Why is the template so big?

Same as above, but we're happy to get your feedback on how to make it smaller.

### Why does the template use so many tools by default (e.g. `hydra`, `wandb`, `black`, etc.)?

This template is mainly addressed to students and researchers at the <lab-name> lab.
Frequently students are not aware of the tools and practices that are available to them, until they face the problems
we've all faced at some point in our career.
We chose to include these tools by default to help students and researchers avoid these problems from the start,
and to encourage them to use them.

### Why does the deployment option on macOS not use Docker?

MPS hardware acceleration is not supported on Docker for
macOS. [(Reference)](https://github.com/pytorch/pytorch/issues/81224).
