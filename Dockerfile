FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8188

RUN apt-get update && apt-get install -y --no-install-recommends \
      git python3 python3-pip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 \
    && python3 -m pip install -r /workspace/ComfyUI/requirements.txt \
    && python3 -m pip install -r /workspace/ComfyUI/custom_nodes/comfyui-manager/requirements.txt \
    && python3 -m pip install --upgrade huggingface_hub \
    && mkdir -p /workspace/.runtime \
    && touch /workspace/.runtime/dependencies.ready \
    && chmod +x /workspace/start.sh /workspace/start-preview.sh /workspace/comfyuiTool/*.sh

EXPOSE 8188
ENTRYPOINT ["bash", "/workspace/comfyuiTool/comfyuiTool.sh"]
