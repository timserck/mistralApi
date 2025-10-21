FROM node:20-bookworm

WORKDIR /app

# Install build dependencies
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

# Copy package files
COPY package.json package-lock.json* ./

# Build node-llama-cpp from source
RUN npm install --build-from-source

# Copy your code
COPY . .

EXPOSE 8000
CMD ["node", "index.js"]
