from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama

app = FastAPI(title="Mistral API on Raspberry Pi")

# 🧠 Load quantized Mistral model (GGUF format)
# Place your model in /models folder when running the container
MODEL_PATH = "/models/mistral-7b-instruct-q4.gguf"
llm = Llama(model_path=MODEL_PATH, n_ctx=4096, n_threads=4)

class Prompt(BaseModel):
    prompt: str
    max_tokens: int = 200

@app.post("/generate")
def generate_text(data: Prompt):
    output = llm(
        data.prompt,
        max_tokens=data.max_tokens,
        stop=["</s>"],
    )
    text = output["choices"][0]["text"]
    return {"response": text}
