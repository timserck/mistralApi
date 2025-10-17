# Base image: lightweight Python
FROM python:3.10-slim

# --- 1. Install essential system dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# --- 2. Use piwheels for precompiled Python packages (faster & low-RAM) ---
RUN mkdir -p /etc/pip && \
    echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /etc/pip/pip.conf

# --- 3. Install Python dependencies ---
RUN pip install --no-cache-dir \
    fastapi \
    "uvicorn[standard]" \
    llama-cpp-python

# --- 4. Add your Mistral 7B model files (or download at runtime) ---
# Example: download model to /models/mistral-7b
RUN mkdir -p /models
# COPY your local model files here if needed
# Alternatively, download from HuggingFace or other source during container start

# --- 5. Set working directory ---
WORKDIR /app
COPY . /app

# --- 6. Expose port and set entrypoint for FastAPI ---
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
