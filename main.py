from fastapi import FastAPI
from llama_cpp import Llama

app = FastAPI()

# Load the Mistral model
# Make sure your model file is mounted in /models
MODEL_PATH = "/models/mistral-7b-q4_k_m.gguf"
llm = Llama(
    model_path=MODEL_PATH,
    n_ctx=4096,        # context size (adjust if needed)
    n_threads=4        # adapt to your Pi's cores
)

@app.get("/")
def root():
    return {"status": "running", "model": "Mistral-7B (quantized)"}

@app.post("/generate")
def generate(prompt: str):
    output = llm(
        prompt,
        max_tokens=256,
        temperature=0.7,
        top_p=0.95,
        repeat_penalty=1.1
    )
    return {"response": output["choices"][0]["text"].strip()}
