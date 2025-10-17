FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

# ✅ Install only essential build dependencies
RUN apt-get update && apt-get install -y \
    python3-dev \
    build-essential \
    gfortran \
    curl \
    pkg-config \
    libssl-dev \
    libclang-dev \
    git \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# ✅ Upgrade pip to avoid build issues
RUN pip install --upgrade pip setuptools wheel

# ✅ Install NumPy precompiled for Raspberry Pi (no BLAS needed)
RUN pip install --extra-index-url https://www.piwheels.org/simple numpy

# Optional: Rust toolchain if needed by some Python packages
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY requirements.txt .

# ✅ Install all Python deps (using piwheels to reduce RAM usage)
RUN pip install --extra-index-url https://www.piwheels.org/simple -r requirements.txt

COPY . .

EXPOSE 8080

# 🏃 Start your FastAPI / Mistral API
CMD ["python", "main.py"]
