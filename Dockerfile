FROM python:3.10-slim-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    curl \
    libopenblas-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure pip to use piwheels (faster for Raspberry Pi)
RUN echo "[global]\nextra-index-url=https://www.piwheels.org/simple" > /etc/pip.conf

# Upgrade pip
RUN pip install --upgrade pip

# Install Python dependencies
RUN pip install --no-cache-dir fastapi "uvicorn[standard]" llama-cpp-python

# Create app directory
WORKDIR /app
COPY . /app

# Expose API port
EXPOSE 8000

# Start server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
