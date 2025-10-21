FROM node:20-bullseye-slim
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential cmake git wget curl libssl-dev python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json* ./
RUN npm install --build-from-source

COPY . .
EXPOSE 8000
CMD ["node", "index.js"]
