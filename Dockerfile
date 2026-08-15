FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    COMFYUI_DIR=/opt/ComfyUI \
    DATA_DIR=/data

RUN apt-get update && apt-get install -y --no-install-recommends \
      git python3 python3-pip ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124 \
    && git clone --depth 1 https://github.com/Comfy-Org/ComfyUI.git ${COMFYUI_DIR} \
    && python3 -m pip install -r ${COMFYUI_DIR}/requirements.txt \
    && python3 -m pip install --upgrade "huggingface_hub[cli]"

COPY start.sh /usr/local/bin/start-comfy
COPY extra_model_paths.yaml ${COMFYUI_DIR}/extra_model_paths.yaml
RUN chmod +x /usr/local/bin/start-comfy

WORKDIR ${COMFYUI_DIR}
EXPOSE 8188
ENTRYPOINT ["/usr/local/bin/start-comfy"]
