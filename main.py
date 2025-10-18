from fastapi import FastAPI
from transformers import pipeline

app = FastAPI()

# Load model at startup
@app.on_event("startup")
def load_model():
    global generator
    generator = pipeline("text-generation", model="mistralai/Mistral-7B-v0.1")

@app.get("/")
def home():
    return {"message": "Mistral 7B API running with PyTorch + Transformers"}

@app.post("/generate")
def generate(prompt: str):
    result = generator(prompt, max_length=100, do_sample=True, temperature=0.7)
    return {"response": result[0]["generated_text"]}
