FROM python:3.10-slim

# Set environment variables to avoid prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Set up pip.conf to use piwheels (for ARM / Raspberry Pi)
RUN mkdir -p /etc && \
    echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip.conf

# Upgrade pip and essential Python build tools
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    llama-cpp-python

# Download Mistral 7B model automatically (optional, adjust path as needed)
RUN mkdir -p /models && \
    wget -O /models/mistral-7b.ggmlv3.q4_0.bin \
    https://huggingface.co/mistral/Mistral-7B-v0/resolve/main/mistral-7b.ggmlv3.q4_0.bin

# Expose port for FastAPI
EXPOSE 8000

# Set working directory
WORKDIR /app

# Copy application files
COPY . /app

# Default command to run FastAPI via uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
