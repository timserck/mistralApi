# -----------------------------
# Stage 1: Build
# -----------------------------
    FROM node:20-bullseye AS build

    WORKDIR /app
    
    # Add bullseye-backports and install CMake + build deps
    RUN echo "deb http://deb.debian.org/debian bullseye-backports main" > /etc/apt/sources.list.d/bullseye-backports.list \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            build-essential \
            git \
            wget \
            curl \
            libssl-dev \
            python3 \
            python3-pip \
            ninja-build \
            ca-certificates \
            cmake/bullseye-backports \
        && rm -rf /var/lib/apt/lists/*
    
    # Verify CMake
    RUN cmake --version && ldd --version
    
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

# Copy only built node_modules, app source, and model
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/package-lock.json* ./package-lock.json
COPY --from=build /app/models ./models
COPY --from=build /app/index.js ./index.js
COPY --from=build /app/*.js ./  # copy other JS files if any

# Set environment variable for model path
ENV MODEL_PATH=/app/models/mistral-7b-v0.1.Q4_0.gguf

# Expose Fastify port
EXPOSE 8000

# Start Node.js server
CMD ["node", "index.js"]