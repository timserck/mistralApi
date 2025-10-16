FROM python:3.9-slim

# Install dependencies and Rust toolchain
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    curl \
    libssl-dev \
    libclang-dev \
    python3-dev \
    git \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc

ENV PATH="/root/.cargo/bin:${PATH}"

# Upgrade pip and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Create model directory and download quantized model
RUN mkdir -p /models \
 && curl -L -o /models/mistral-7b-instruct-v0.2.Q4_K_M.gguf \
    https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf

# Copy app
COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
