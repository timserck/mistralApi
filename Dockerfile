# Use an official Python slim image for ARM
FROM python:3.10-slim-bullseye

# Set environment variables to reduce RAM usage during builds
ENV DEBIAN_FRONTEND=noninteractive
ENV MAKEFLAGS="-j1"
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DEFAULT_TIMEOUT=100

# Update and install dependencies for Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    pkg-config \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configure pip to use piwheels for prebuilt ARM packages
RUN mkdir -p /etc/pip.conf && \
    echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip.conf

# Copy requirements.txt
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Copy your application code
COPY . /app
WORKDIR /app

# Expose port (if using an API)
EXPOSE 8000

# Default command
CMD ["python3", "app.py"]
