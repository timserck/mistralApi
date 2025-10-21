FROM node:20-bullseye-slim

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    libssl-dev \
    python3 \
    ninja-build \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install a modern CMake (>=3.25)
RUN wget -qO- https://cmake.org/files/v3.27/cmake-3.27.9-linux-x86_64.tar.gz | tar --strip-components=1 -xz -C /usr/local

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies (build node-llama-cpp from source)
RUN npm install --build-from-source

# Copy source code
COPY . .

EXPOSE 8000
CMD ["node", "index.js"]
