from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# Choose a Pi-friendly model (quantized or small version)
MODEL_NAME = "mistralai/Mistral-7B-Instruct-v0-q4"  # example
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForCausalLM.from_pretrained(MODEL_NAME, device_map="cpu")

app = FastAPI(title="Mistral API on Raspberry Pi")

class Request(BaseModel):
    prompt: str
    max_length: int = 50

@app.post("/generate")
def generate_text(req: Request):
    inputs = tokenizer(req.prompt, return_tensors="pt")
    outputs = model.generate(**inputs, max_length=req.max_length)
    text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return {"generated_text": text}
