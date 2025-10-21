# Use Ubuntu-based Node image (glibc available)
FROM node:20-bullseye

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

# Install CMake 3.27+ (ARM64)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.27.8/cmake-3.27.8-linux-aarch64.sh \
    && chmod +x cmake-3.27.8-linux-aarch64.sh \
    && mkdir /opt/cmake \
    && ./cmake-3.27.8-linux-aarch64.sh --skip-license --prefix=/opt/cmake \
    && rm cmake-3.27.8-linux-aarch64.sh \
    && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

# Verify CMake
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

ENV MODEL_PATH=/app/models/mistral-7b-v0.1.Q4_0.gguf

EXPOSE 8000

CMD ["node", "index.js"]
