from fastapi import FastAPI
from pydantic import BaseModel
from llama_cpp import Llama

# Load model at startup
llm = Llama(
    model_path="/models/mistral-7b-instruct-v0.2.Q4_K_M.gguf",
    n_threads=4
)

app = FastAPI()

class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
def generate(req: PromptRequest):
    output = llm(
        req.prompt,
        max_tokens=256,
        temperature=0.7,
    )
    return {"response": output["choices"][0]["text"]}
