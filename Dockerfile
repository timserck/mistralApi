# Use lightweight Python base image
FROM python:3.10-slim

# Set environment variables for low RAM builds
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install necessary build tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    gfortran \
    libffi-dev \
    libssl-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    unzip \
    git \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create temporary swapfile to avoid memory issues during build
RUN fallocate -l 1G /swapfile && \
    chmod 600 /swapfile && \
    mkswap /swapfile && \
    swapon /swapfile

# Configure pip to use piwheels (for ARM / low RAM)
RUN mkdir -p /etc/pip.conf && \
    echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip.conf/pip.conf

# Copy requirements first for caching
COPY requirements.txt /tmp/requirements.txt

# Upgrade pip & install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --verbose -r /tmp/requirements.txt

# Turn off swap and remove swapfile to clean up
RUN swapoff /swapfile && rm /swapfile

# Copy app code
WORKDIR /app
COPY . /app

# Expose app port
EXPOSE 8000

# Default command
CMD ["python", "app.py"]
