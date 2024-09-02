from transformers import AutoModelForCausalLM
from transformers import AutoTokenizer


model_name = "meta-llama/Meta-Llama-3.1-8B"
model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto")
tokenizer = AutoTokenizer.from_pretrained(model_name, padding_side="left")
if not hasattr(tokenizer, "pad_token"):
    tokenizer.pad_token = tokenizer.eos_token

history = ""

def chat(text, max_tokens=50):
    global history
    model_inputs = tokenizer([history + text], return_tensors="pt").to("cuda")
    generated_ids = model.generate(**model_inputs, max_new_tokens=max_tokens, do_sample=True)
    res = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
    history = res
    print(res)


def reset():
    global history
    history = ""