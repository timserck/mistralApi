# Use Debian with good package support
FROM python:3.10-bullseye

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    libopenblas-dev \
    git \
    curl \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# Optional: use piwheels for faster installs on Raspberry Pi
RUN echo "[global]\nextra-index-url=https://www.piwheels.org/simple" > /etc/pip.conf

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install FastAPI + llama-cpp-python (compilation here)
RUN pip install --no-cache-dir fastapi "uvicorn[standard]" llama-cpp-python

# Set working directory
WORKDIR /app

# Copy API code
COPY main.py /app

# Expose API port
EXPOSE 8000

# Launch FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
