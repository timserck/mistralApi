from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama

# Load the model at startup (use fewer threads if Pi is low-power)
llm = Llama(
    model_path="/models/mistral-7b-instruct-v0.2.Q4_K_M.gguf",
    n_threads=4
)

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate(req: PromptRequest):
    result = llm(
        req.prompt,
        max_tokens=256,
        temperature=0.7
    )
    return {"response": result["choices"][0]["text"]}
