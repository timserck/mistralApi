# Use official Python 3.10 slim image (ARM-friendly)
FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    python3-dev \
    gfortran \
    libblas-dev \
    liblapack-dev \
    wget \
 && rm -rf /var/lib/apt/lists/*

# Configure pip to use piwheels (ARM prebuilt wheels)
RUN mkdir -p /etc/pip.conf \
 && echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip.conf

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Download Mistral 7B GGML model
RUN mkdir -p /models/mistral7b && \
    wget -O /models/mistral7b/mistral-7b.ggmlv3.q4_0.bin \
    https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.1/resolve/main/mistral-7b-instruct-v0.1.ggmlv3.q4_0.bin

# Copy app code
COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
