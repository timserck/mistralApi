# Use a lightweight Python base image compatible with Raspberry Pi aarch64
FROM python:3.10-slim

# Install system build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    libopenblas-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Optional: configure piwheels to speed up other installs
RUN echo "[global]\nextra-index-url=https://www.piwheels.org/simple" > /etc/pip.conf

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Increase swap to help build llama-cpp-python
# (This is only during build. Can't use swapon in Docker, so we use dphys-swapfile-like workaround)
# If you have build errors due to memory, build this image with: 
#   docker build --memory=4g --memory-swap=4g .
# OR build on host then copy wheel.

# Install Python dependencies
RUN pip install --no-cache-dir fastapi "uvicorn[standard]" llama-cpp-python

# Create working directory
WORKDIR /app

# Copy your FastAPI app
COPY main.py /app

# Expose port
EXPOSE 8000

# Start server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
