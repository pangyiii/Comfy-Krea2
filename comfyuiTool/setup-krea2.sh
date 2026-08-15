#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMFYUI_DIR="/workspace/ComfyUI"
DATA_DIR="${PROJECT_DIR}/.data"
MODEL_DIR="${DATA_DIR}/models"
MANAGER_DIR="${COMFYUI_DIR}/custom_nodes/comfyui-manager"
MANAGER_MARKER="${DATA_DIR}/.manager-dependencies-installed"
MODEL_REPO="${KREA_MODEL_REPO:-Comfy-Org/Krea-2}"

[[ -f "${COMFYUI_DIR}/main.py" ]] || { echo "Missing /workspace/ComfyUI template."; exit 1; }
mkdir -p "${MODEL_DIR}/diffusion_models" "${MODEL_DIR}/text_encoders" "${MODEL_DIR}/vae" "${MODEL_DIR}/loras"

if ! command -v hf >/dev/null 2>&1; then
  python3 -m pip install --user --upgrade "huggingface_hub[cli]"
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ ! -d "${MANAGER_DIR}/.git" ]]; then
  git clone --depth 1 https://github.com/Comfy-Org/ComfyUI-Manager.git "${MANAGER_DIR}"
fi

if [[ ! -f "${MANAGER_MARKER}" && -f "${MANAGER_DIR}/requirements.txt" ]]; then
  python3 -m pip install -r "${MANAGER_DIR}/requirements.txt"
  touch "${MANAGER_MARKER}"
fi

hf download "${MODEL_REPO}" \
  --include "diffusion_models/krea2_turbo_fp8_scaled.safetensors" \
  --include "text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
  --include "vae/qwen_image_vae.safetensors" \
  --local-dir "${MODEL_DIR}"

echo "Krea 2 Turbo FP8 and ComfyUI-Manager are ready. Switch to GPU A10 and start Preview."
