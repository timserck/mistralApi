# Use Ubuntu-based Node image (glibc available)
FROM node:20-bullseye

WORKDIR /app

# Install system dependencies (without old CMake)
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

# Upgrade CMake to 3.27+ (ARM compatible)
RUN mkdir -p /opt/cmake \
    && wget https://github.com/Kitware/CMake/releases/download/v3.27.8/cmake-3.27.8-linux-aarch64.sh \
    && chmod +x cmake-3.27.8-linux-aarch64.sh \
    && ./cmake-3.27.8-linux-aarch64.sh --skip-license --prefix=/opt/cmake \
    && rm cmake-3.27.8-linux-aarch64.sh

# Add CMake to PATH
ENV PATH="/opt/cmake/bin:$PATH"

# Verify cmake and glibc
RUN cmake --version && ldd --version

# Copy package files
COPY package.json package-lock.json* ./

# Install Node dependencies from source
RUN npm install --build-from-source

# Copy app source code
COPY . .

# Download Mistral 7B GGUF model
RUN mkdir -p /app/models \
    && wget -O /app/models/mistral-7b-v0.1.Q4_0.gguf \
       "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_0.gguf"

# Set environment variable for model path
ENV MODEL_PATH=/app/models/mistral-7b-v0.1.Q4_0.gguf

# Expose Fastify port
EXPOSE 8000

# Start Node.js server
CMD ["node", "index.js"]
