# Use a full Node image with build tools
FROM node:20-bookworm

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    libssl-dev \
    python3 \
    python3-pip \
    ninja-build \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install latest CMake (required by node-llama-cpp)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.27.8/cmake-3.27.8-linux-x86_64.sh \
    && sh cmake-3.27.8-linux-x86_64.sh --skip-license --prefix=/usr/local

# Copy package files and install Node dependencies
COPY package.json package-lock.json* ./
RUN npm install --build-from-source

# Copy app source
COPY . .

# Download Mistral 7B GGUF model
RUN mkdir -p /app/models \
    && wget -O /app/models/mistral-7b-v0.1.Q4_0.gguf \
       "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_0.gguf"

# Set environment variable for model path
ENV MODEL_PATH=/app/models/mistral-7b-v0.1.Q4_0.gguf

# Expose Fastify port
EXPOSE 8000

# Start the Node.js server
CMD ["node", "index.js"]
