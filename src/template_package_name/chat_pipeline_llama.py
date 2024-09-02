import transformers
import torch

model_id = "meta-llama/Meta-Llama-3.1-8B"

pipeline = transformers.pipeline(
    "text-generation", model=model_id, model_kwargs={"torch_dtype": torch.bfloat16}, device_map="auto"
)

chats = [""]

def chat(request):
    response = pipeline(chats[-1] + request, max_new_tokens=128)[0]["generated_text"]
    print(response)
    chats.append(response)

chat("hello, who are you?")