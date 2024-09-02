# imports
from datasets import load_dataset
from trl import SFTTrainer

# get dataset
dataset = load_dataset("imdb", split="train")

# get trainer
trainer = SFTTrainer(
    "facebook/opt-350m",
    train_dataset=dataset,
    dataset_text_field="text",
    max_seq_length=512,
)

# train
trainer.train()