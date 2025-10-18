FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake libffi-dev wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add piwheels (optional)
RUN mkdir -p /root/.pip && echo "[global]\nextra-index-url = https://www.piwheels.org/simple" > /root/.pip/pip.conf

RUN python -m pip install --upgrade pip setuptools wheel

# --- Install llama-cpp-python wheel ---
ADD llama_cpp_python-0.2.76-cp311-cp311-linux_aarch64.whl .
RUN pip install ./llama_cpp_python-0.2.76-cp311-cp311-linux_aarch64.whl

# --- Install other Python deps ---
RUN pip install fastapi "uvicorn[standard]" huggingface_hub

WORKDIR /app
COPY . /app

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
