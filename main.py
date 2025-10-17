from fastapi import FastAPI
from llama_cpp import Llama

app = FastAPI()

# Load your model (mount it into /models)
llm = Llama(model_path="/models/your_model.gguf")

@app.get("/")
def root():
    return {"status": "running"}

@app.post("/generate")
def generate(prompt: str):
    output = llm(prompt, max_tokens=128)
    return {"response": output["choices"][0]["text"]}
