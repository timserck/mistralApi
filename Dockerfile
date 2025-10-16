FROM python:3.11-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PIP_INDEX_URL=https://www.piwheels.org/simple
ENV PIP_EXTRA_INDEX_URL=https://pypi.org/simple

RUN apt-get update && apt-get install -y git build-essential && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# ✅ Install PyTorch from PiWheels (ARM64 community build)
RUN pip install torch torchvision torchaudio

# Install other dependencies
RUN pip install fastapi uvicorn[standard] transformers accelerate

COPY app.py .

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

