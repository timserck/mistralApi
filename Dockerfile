FROM python:3.10-slim

# Install system dependencies needed for building packages on aarch64
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    ninja-build \
    autoconf \
    automake \
    libtool \
    gawk \
    curl \
    git \
    python3-dev \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Environment variables to make llama-cpp build lighter
ENV CMAKE_ARGS="-DLLAMA_CUBLAS=OFF -DLLAMA_BLAS=OFF"
ENV FORCE_CMAKE=1

WORKDIR /app

# Copy dependencies
COPY requirements.txt .

# Upgrade pip & install Python dependencies
RUN pip install --upgrade pip
RUN pip install --verbose -r requirements.txt

# Copy the app
COPY app.py .

# Make sure the models folder exists inside the container
RUN mkdir -p /models

EXPOSE 8000

# Start FastAPI
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
