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
    # System dependencies
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
    # Configure pip to use piwheels
    # ---------------------------
    RUN mkdir -p /root/.pip && echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /root/.pip/pip.conf
    
    # ---------------------------
    # Upgrade pip
    # ---------------------------
    RUN python -m pip install --upgrade pip setuptools wheel
    
    # ---------------------------
    # Install Python dependencies
    # torch & transformers should be pulled from piwheels
    # ---------------------------
    RUN pip install --no-cache-dir \
        fastapi \
        "uvicorn[standard]" \
        huggingface_hub \
        transformers \
        torch
    
    # ---------------------------
    # Create model directory
    # ---------------------------
    RUN mkdir -p $MODEL_PATH
    
    # ---------------------------
    # (Optional) Download Mistral 7B model from Hugging Face
    # ---------------------------
    RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('mistralai/Mistral-7B-v0.1', cache_dir='$MODEL_PATH')"
    
    # ---------------------------
    # Expose API port
    # ---------------------------
    EXPOSE 8000
    
    # ---------------------------
    # Set working directory & copy app
    # ---------------------------
    WORKDIR /app
    COPY . /app
    
    # ---------------------------
    # Run the API
    # ---------------------------
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
    