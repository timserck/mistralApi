# Use an official Python base image
FROM python:3.10-slim

# Install system dependencies needed for Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        ca-certificates \
        libffi-dev \
        libssl-dev \
        && rm -rf /var/lib/apt/lists/*

# Configure pip to use piwheels (prebuilt wheels for ARM / low-RAM)
RUN mkdir -p /etc/pip && \
    echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip/pip.conf

# Upgrade pip, setuptools, wheel
RUN pip install --upgrade pip setuptools wheel

# Copy your requirements file
COPY requirements.txt .

# Install Python dependencies using prebuilt wheels when possible
RUN pip install --no-cache-dir -r requirements.txt

# Copy your app code
COPY . /app
WORKDIR /app

# Default command
CMD ["python", "main.py"]
