# Use a full Node image with build tools
FROM node:20-bookworm

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    libssl-dev \
    python3 \
    python3-pip \
    ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy package files and install Node dependencies
COPY package.json package-lock.json* ./
RUN npm install --build-from-source

# Copy app source
COPY . .

# Download Mistral 7B ggml model
RUN mkdir -p /app/models \
    && wget -O /app/models/ggml-mistral-7b-q4_0.bin \
       "https://huggingface.co/mistralai/Mistral-7B-v0.1/resolve/main/ggml-mistral-7b-q4_0.bin"

# Set environment variable for model path
ENV MODEL_PATH=/app/models

# Expose Fastify port
EXPOSE 8000

# Start the Node.js server
CMD ["node", "index.js"]
