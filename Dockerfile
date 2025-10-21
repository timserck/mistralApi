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
    apt-transport-https \
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add Kitware APT repo for latest CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/debian/ bullseye main' > /etc/apt/sources.list.d/kitware.list \
    && apt-get update && apt-get install -y cmake \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify CMake and glibc
RUN cmake --version && ldd --version

# Copy package files
COPY package.json package-lock.json* ./

# Force system cmake for node-llama-cpp
ENV PATH="/usr/bin:$PATH"

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
