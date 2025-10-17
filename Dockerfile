FROM python:3.9-slim

# Install system deps, Rust toolchain, and build essentials
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    curl \
    libssl-dev \
    libclang-dev \
    python3-dev \
    git \
    rustc \
    cargo \
 && rm -rf /var/lib/apt/lists/*

# Copy Python requirements
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Create model directory and download quantized Mistral model
RUN mkdir -p /models \
 && curl -L -o /models/mistral-7b-instruct-v0.2.Q4_K_M.gguf \
    https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf

# Copy the API application
COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
