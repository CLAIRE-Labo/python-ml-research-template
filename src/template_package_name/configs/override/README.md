The configs in this directory should not be tracked by git.
They are meant to be used as overrides for the configs in the `configs` directory.
Use them only for development (e.g., disable wandb, reduce the number of epochs, etc.).
E.g., you could have an `override/setup.yaml` doing something like:
```yaml
wandb:
  mode: disabled

optim:
  num_epochs: 1
```

As done for `.../override/some_experiment.yaml` in `config/some_experiment.yaml`
put the override config as the last one to be read by the experiment config (the last one it its defaults).
It will override any variable set there.
Remember to comment everything out for your actual runs, or even better maintain two
different copies of the repo: one for development and one for unattended runs to avoid edits
while you develop to be picked up by your unattended runs.
