# ---- Base image ----
    FROM python:3.11-slim

    # ---- Environment ----
    ENV PIP_NO_CACHE_DIR=1 \
        PIP_DISABLE_PIP_VERSION_CHECK=1 \
        PYTHONUNBUFFERED=1
    
    # ---- Install system dependencies ----
    RUN apt-get update && apt-get install -y \
        build-essential \
        cmake \
        git \
        curl \
        libomp-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
    
    # ---- Use prebuilt wheels ----
    RUN pip install --upgrade pip setuptools wheel
    
    # ---- Install Python packages ----
    RUN pip install --prefer-binary fastapi "uvicorn[standard]" llama-cpp-python
    
    # ---- Copy your app ----
    WORKDIR /app
    COPY . /app
    
    # ---- Expose port ----
    EXPOSE 8000
    
    # ---- Start the app ----
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
    