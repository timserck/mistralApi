from fastapi import FastAPI
from llama_cpp import Llama

app = FastAPI(title="Mistral 7B FastAPI API")

# Load Mistral 7B model
llm = Llama(
    model_path="/models/mistral7b/mistral-7b.ggmlv3.q4_0.bin",
    n_threads=4  # Adjust based on your CPU cores
)

@app.get("/")
async def root():
    return {"message": "Mistral 7B API is running!"}

@app.post("/generate")
async def generate(prompt: str):
    output = llm(prompt, max_tokens=256)
    return {"prompt": prompt, "response": output["text"]}
