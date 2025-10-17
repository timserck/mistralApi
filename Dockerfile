# ---------------------------
# Base image
# ---------------------------
    FROM python:3.11-slim

    # ---------------------------
    # Environment setup
    # ---------------------------
    ENV DEBIAN_FRONTEND=noninteractive
    ENV LANG=C.UTF-8
    ENV MODEL_PATH=/models/mistral-7b
    
    # ---------------------------
    # Install minimal system dependencies
    # ---------------------------
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        curl \
        wget \
        libffi-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # ---------------------------
    # Upgrade pip
    # ---------------------------
    RUN python -m pip install --upgrade pip setuptools wheel
    
    # ---------------------------
    # Install FastAPI + Uvicorn + HF Hub
    # ---------------------------
    RUN pip install --no-cache-dir \
        fastapi \
        "uvicorn[standard]" \
        huggingface_hub
    
    # ---------------------------
    # Pre-install llama-cpp-python if a binary wheel is available
    # ---------------------------
    # Force pip to use only prebuilt wheels
    RUN pip install --no-cache-dir --only-binary=:all: llama-cpp-python || echo "Skipping llama-cpp-python build"
    
    # ---------------------------
    # Create model directory
    # ---------------------------
    RUN mkdir -p $MODEL_PATH
    
    # ---------------------------
    # Download Mistral 7B model
    # ---------------------------
    RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('mistralai/Mistral-7B-v0.1', cache_dir='$MODEL_PATH')"
    
    # ---------------------------
    # Expose FastAPI port
    # ---------------------------
    EXPOSE 8000
    
    # ---------------------------
    # Set working directory
    # ---------------------------
    WORKDIR /app
    
    # ---------------------------
    # Copy your app
    # ---------------------------
    COPY . /app
    
    # ---------------------------
    # Run Uvicorn
    # ---------------------------
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
    