FROM node:20-bullseye-slim

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json* ./

# Force npm to build llama-cpp-node from source
RUN npm install --build-from-source

COPY . .

EXPOSE 8000
CMD ["node", "index.js"]
