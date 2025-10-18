from fastapi import FastAPI
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

MODEL_PATH = "/models/mistral-7b"

app = FastAPI()

# Load model and tokenizer at startup
@app.on_event("startup")
def load_model():
    global model, tokenizer
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_PATH,
        torch_dtype=torch.float32,
        device_map="cpu"
    )

@app.get("/")
def root():
    return {"message": "Mistral 7B API is running!"}

@app.post("/generate")
def generate_text(prompt: str):
    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(
        **inputs,
        max_new_tokens=100,
        do_sample=True,
        top_p=0.9,
        temperature=0.7
    )
    text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return {"prompt": prompt, "response": text}
