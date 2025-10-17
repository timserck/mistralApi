FROM python:3.9-slim

# Install dependencies including rustc and cargo from apt
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

# Copy requirements and install Python deps
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Download Mistral model
RUN mkdir -p /models \
 && curl -L -o /models/mistral-7b-instruct-v0.2.Q4_K_M.gguf \
    https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf

# Copy app
COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
