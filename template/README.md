# Additional Details about the Template

## Reproducibility and replicability

This template ensures the reproducibility of your results through 3 artifacts:

- The development environment, strictly recorded in environment files:
    - Python dependencies in the conda environment.
    - System dependencies in the `apt` files for the Docker option and less strictly with brew for the Apple Silicon
      option.
    - The whole environment can also be recovered from the Docker image without building it again.
- The project code.
    - Recorded in the git repository.
- The data.
    - Up to you to record it, but we provide a common directory structure across all installation methods.

## Directory structure

The template sets the following directory structure across all installation methods:

```text
PROJECT_ROOT/        # The root of the project (opt/project on the AMD64 setup and template-project-name on the macOS setup).
├── PROJECT_NAME/  # The root of the git repository.
├── data/            # This is from where the data will be read.
├── outputs/         # This is where the outputs will be written.
└── wandb/           # This is where wandb artifacts will be written.
```

The structure does not enforce storing the data and outputs physically under the same directory as the project,
instead these will be symlinks, contain symlinks, or be mounted directories.

The point of this structure is to keep the python code identical across installation methods and platforms.
In particular, the `hydra` configuration files will be the same,
instructing your scripts to read from and write to the same directories.

It also allows as much freedom as possible (e.g. mount data from one filesystem, outputs from another, etc.) while
respecting the best practices and limitations of all deployment options
(e.g. not having nested mounts in a Docker container)
and providing a great user experience on all platforms
(e.g. we could have used environment variables to specify the paths, but we find them not as convenient to use,
particularly on the native Apple Silicon option, where cannot set them automatically for you,
which means you have to remember to set them every time.
Furthermore, we want to keep the template as contained as possible, which means not altering the user's global
environment.)

This may add dome configuration steps at the beginning, that may differ on the platform and add some
boilerplate code, but then we have a seamless experience.

## Template FAQ

### Why Docker? Why not just Conda? (At least for the AMD64 setup.)

1. Conda environments are not so self-contained, some packages can just work on your machine because they use some of
   your system libraries.
   The environment will not run on another machine missing those libraries.
2. Reinforcement learning (RL) environments usually require system libraries not available in Conda
   and RL is a big part of our work.

To record those faithfully, we use Docker.

### Why does the deployment option on macOS not use Docker?

MPS hardware acceleration is not supported on Docker for
macOS. [(Reference)](https://github.com/pytorch/pytorch/issues/81224).

### Why is the template so complex?

It probably seems complex at first sight because you are not familiar with the tools and practices it uses.
However, these practices (usually not all combined in a research project, whence this template) are
well established and have been proven to be very useful.

For example the `Dockerfile` seems complex because it leverages multi-staging to be very
time and cache-efficient.
Different build stages can run in parallel and changing your build dependencies,
or installing something in the Dockerfile will cause very little rebuilds.

Using Docker Compose is also very convenient to define all the build arguments and multiple deployment options
in a single file, avoiding long build and run commands

### Why does the template include so many files?

Same as above, but we're happy to get your feedback on how to make it smaller.

### Why does the template use so many tools by default (e.g. `hydra`, `wandb`, `black`, etc.)?

This template is mainly addressed to students and researchers at the CLAIRe (tentative name) lab.
Frequently students are not aware of the tools and practices that are available to them, until they face the problems
we've all faced at some point in our career.
We chose to include these tools by default to help students and researchers avoid these problems from the start,
and to encourage them to use them.

### Can I use this template for an already existing project? How do I do that?

Yes. It's likely that your project is a bunch of Python files and a `requirements.txt` or `environment.yml` file.
You can copy those files and potentially refactor the package structures and put all of them under `src`.
You will also have to transfer the dependencies to the `environment.yml` file and identify the system dependencies.

We recommend you start the template as if you were creating a new project and then copy your files over and add the
relevant dependencies.
