# Start from a lightweight Python base
FROM python:3.10-slim

# --- 1. Set environment variables ---
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PIP_NO_CACHE_DIR=1

# --- 2. Install system dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev \
    libgomp1 \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# --- 3. Optional: create swap for low RAM systems ---
# This allows pip to compile heavy packages without OOM
RUN fallocate -l 2G /swapfile || true && \
    chmod 600 /swapfile || true && \
    mkswap /swapfile || true && \
    swapon /swapfile || true

# --- 4. Configure pip to use piwheels (for ARM / Raspberry Pi) ---
RUN mkdir -p /etc/pip && echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip/pip.conf

# --- 5. Copy requirements (if you have a requirements.txt) ---
# Otherwise, install packages directly
# COPY requirements.txt /app/requirements.txt

# --- 6. Install Python packages ---
RUN pip install --upgrade pip setuptools wheel
RUN pip install fastapi "uvicorn[standard]" llama-cpp-python

# --- 7. Set working directory ---
WORKDIR /app

# --- 8. Copy your app code ---
# COPY . /app

# --- 9. Expose port for FastAPI ---
EXPOSE 8000

# --- 10. Run the API ---
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
