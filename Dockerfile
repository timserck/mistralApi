# ✅ Use Debian Bookworm as base — better package support on Raspberry Pi
FROM python:3.10-bullseye

# Install system build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    libopenblas-dev \
    git \
    curl \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# Optional: use piwheels to speed up installs for other Python packages
RUN echo "[global]\nextra-index-url=https://www.piwheels.org/simple" > /etc/pip.conf

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install Python dependencies including llama-cpp-python (this will compile from source)
RUN pip install --no-cache-dir fastapi "uvicorn[standard]" llama-cpp-python

# Set working directory
WORKDIR /app

# Copy your FastAPI application code
COPY main.py /app

# Expose API port
EXPOSE 8000

# Run FastAPI with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
