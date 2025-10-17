# Use Python base image for ARM64
FROM python:3.10-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies required by numpy, torch, rust-based packages, etc.
RUN apt-get update && apt-get install -y \
    python3-dev \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    build-essential \
    curl \
    pkg-config \
    libssl-dev \
    libclang-dev \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tools
RUN pip install --upgrade pip setuptools wheel

# Install numpy from piwheels to avoid heavy build
RUN pip install --extra-index-url https://www.piwheels.org/simple numpy

# Optional: reduce memory during builds
ENV NPY_NUM_BUILD_JOBS=1

# (Optional) Install rust if you have packages like maturin that require it
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc

# Add Rust to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Copy your project files
WORKDIR /app
COPY requirements.txt .

# Install Python dependencies from piwheels when possible
RUN pip install --extra-index-url https://www.piwheels.org/simple -r requirements.txt

# Copy the rest of your code
COPY . .

# Expose port 8080 (change if needed)
EXPOSE 8080

# Start your FastAPI / mistral API server
CMD ["python", "main.py"]
