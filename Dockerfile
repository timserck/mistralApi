FROM node:20-bookworm

WORKDIR /app

# Install build dependencies and wget
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    libssl-dev \
    python3 \
    ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm install --build-from-source

# Copy app source
COPY . .

# Create models folder and download model
RUN mkdir -p /app/models \
    && wget -O /app/models/ggml-model.bin "https://huggingface.co/your-model-repo/resolve/main/ggml-model.bin"

# Set environment variable
ENV MODEL_PATH=/app/models

EXPOSE 8000
CMD ["node", "index.js"]
