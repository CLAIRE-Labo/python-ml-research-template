from peft import AutoPeftModelForCausalLM
import torch


model = AutoPeftModelForCausalLM.from_pretrained(
    "third-party/trl/dpo/final_checkpoint",
    low_cpu_mem_usage=True,
    torch_dtype=torch.float16,
    load_in_4bit=True,
)

model.generate()