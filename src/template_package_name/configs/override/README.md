The configs in this directory should not be tracked by git.
They are meant to be used as personalized overrides for the configs in the `configs` directory.
You can use them temporarily for development (e.g., disable wandb, reduce the number of epochs, etc.)
or to specify configurations specific to your machine (e.g., the number of GPUs to use).
E.g., you could have an `override/setup.yaml` doing something like:

```yaml
wandb:
  mode: disabled

optim:
  num_epochs: 1
```

As done for `.../override/template_experiment.yaml` in `config/template_experiment.yaml`
put the override config as the last one to be read by the experiment config (the last one it its defaults).
It will override any variable set there.
Remember to remove everything that's not hardware dependent for your reproducible runs,
or even better maintain two different copies of the repo:
one for development and one for unattended runs to avoid edits
while you develop to be picked up by your unattended runs.
