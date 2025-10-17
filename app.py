from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama
import os

# Load the model (GGUF format)
MODEL_PATH = "/models/mistral-7b-instruct-v0.2.Q4_K_M.gguf"

if not os.path.exists(MODEL_PATH):
    raise RuntimeError(f"Model not found at {MODEL_PATH}. Place your GGUF file there.")

llm = Llama(model_path=MODEL_PATH, n_threads=4, n_ctx=2048)

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate_text(request: PromptRequest):
    output = llm(
        request.prompt,
        max_tokens=256,
        stop=["</s>"],
        echo=False
    )
    return {"response": output["choices"][0]["text"]}
