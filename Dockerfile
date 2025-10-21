# -----------------------------
# Stage 1: Build
# -----------------------------
    FROM node:20-bullseye AS build

    WORKDIR /app
    
    # Install build dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        curl \
        libssl-dev \
        python3 \
        python3-pip \
        ninja-build \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*
    
    # Install latest CMake (ARM)
    RUN mkdir -p /opt/cmake \
        && wget https://github.com/Kitware/CMake/releases/download/v3.27.8/cmake-3.27.8-linux-aarch64.sh \
        && chmod +x cmake-3.27.8-linux-aarch64.sh \
        && ./cmake-3.27.8-linux-aarch64.sh --skip-license --prefix=/opt/cmake \
        && rm cmake-3.27.8-linux-aarch64.sh
    
    # Add CMake to PATH
    ENV PATH="/opt/cmake/bin:$PATH"
    
    # Verify CMake
    RUN /opt/cmake/bin/cmake --version && ldd --version
    
    # Copy package files and install dependencies
    COPY package.json package-lock.json* ./
    RUN npm install --build-from-source
    
    # Copy source code
    COPY . .
    
    # Download Mistral 7B GGUF model
    RUN mkdir -p /app/models \
        && wget -O /app/models/mistral-7b-v0.1.Q4_0.gguf \
           "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_0.gguf"
    
    # -----------------------------
    # Stage 2: Runtime
    # -----------------------------
    FROM node:20-bullseye-slim
    
    WORKDIR /app
    
    # Copy built node_modules, app source, and model
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package.json ./package.json
    COPY --from=build /app/package-lock.json* ./package-lock.json
    COPY --from=build /app/models ./models
    COPY --from=build /app/index.js ./index.js
    COPY --from=build /app/*.js ./  # copy any other JS files
    
    # Set environment variable for model path
    ENV MODEL_PATH=/app/models/mistral-7b-v0.1.Q4_0.gguf

    # Expose Fastify port
    EXPOSE 8000

    # Start Node.js server
    CMD ["node", "index.js"]