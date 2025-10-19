# ---------------------------
# Base image
# ---------------------------
    FROM node:20-slim

    # ---------------------------
    # Environment
    # ---------------------------
    ENV DEBIAN_FRONTEND=noninteractive
    ENV LANG=C.UTF-8
    ENV MODEL_PATH=/models/mistral-7b
    
    # ---------------------------
    # Install system dependencies
    # ---------------------------
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        wget \
        git \
        python3 \
        python3-pip \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    
    # ---------------------------
    # Install Node.js dependencies
    # ---------------------------
    WORKDIR /app
    COPY package*.json ./
    
    RUN npm install
    
    # ---------------------------
    # Copy app source code
    # ---------------------------
    COPY . /app
    
    # ---------------------------
    # Create model directory
    # ---------------------------
    RUN mkdir -p $MODEL_PATH
    
    # ---------------------------
    # Download Mistral 7B model (ggml quantized)
    # ---------------------------
    # You must provide a ggml version compatible with llama.cpp
    # Example: wget -O $MODEL_PATH/ggml-model.bin <link-to-ggml-model>
    # RUN wget -O $MODEL_PATH/ggml-model.bin <URL>
    
    # ---------------------------
    # Expose API port
    # ---------------------------
    EXPOSE 8000
    
    # ---------------------------
    # Start Node.js server
    # ---------------------------
    CMD ["node", "index.js"]
    