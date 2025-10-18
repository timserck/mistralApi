from fastapi import FastAPI
from llama_cpp import Llama

app = FastAPI()
llm = None

@app.on_event("startup")
def load_model():
    global llm
    llm = Llama(model_path="/models/mistral-7b/ggml-model-q4_0.gguf")  # make sure you have a quantized .gguf model

@app.get("/")
def home():
    return {"message": "Mistral 7B API is running on llama.cpp"}

@app.post("/generate")
def generate(prompt: str):
    output = llm(prompt, max_tokens=100)
    return {"response": output["choices"][0]["text"]}
