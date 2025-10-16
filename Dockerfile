# ✅ Use Python 3.9 — compatible with piwheels PyTorch builds
FROM python:3.9-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Use piwheels for Raspberry Pi ARM builds
ENV PIP_INDEX_URL=https://www.piwheels.org/simple
ENV PIP_EXTRA_INDEX_URL=https://pypi.org/simple

RUN apt-get update && apt-get install -y git build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# ✅ Install PyTorch from piwheels (ARM-compatible)
RUN pip install torch torchvision torchaudio

# Install API + transformer stack
RUN pip install fastapi uvicorn[standard] transformers accelerate

# Copy your API app
COPY app.py .

# Expose API port
EXPOSE 8000

# Run server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
