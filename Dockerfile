# ---- Base image ----
    FROM python:3.11-slim

    # ---- Environment ----
    ENV PIP_NO_CACHE_DIR=1 \
        PIP_DISABLE_PIP_VERSION_CHECK=1 \
        PYTHONUNBUFFERED=1 \
        MODEL_DIR=/app/models
    
    # ---- Install system dependencies ----
    RUN apt-get update && apt-get install -y \
        build-essential \
        cmake \
        git \
        curl \
        libomp-dev \
        wget \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    
    # ---- Upgrade pip and install Python packages ----
    RUN pip install --upgrade pip setuptools wheel
    RUN pip install --prefer-binary fastapi "uvicorn[standard]" llama-cpp-python
    
    # ---- Create model folder ----
    RUN mkdir -p $MODEL_DIR
    
    # ---- Copy your app ----
    WORKDIR /app
    COPY . /app
    
    # ---- Expose port ----
    EXPOSE 8000
    
    # ---- Download Mistral 7B weights (example using huggingface) ----
    # Replace URL with actual weights URL if needed
    # Optional: Uncomment the next lines if you want auto-download at build
    # RUN wget -O $MODEL_DIR/mistral-7b.bin "https://huggingface.co/mistralai/Mistral-7B-Instruct-v0/resolve/main/mistral-7b-instruct-v0.bin"
    
    # ---- Start FastAPI app ----
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
    