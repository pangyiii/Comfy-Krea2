#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMFYUI_DIR="${PROJECT_DIR}/ComfyUI"
MODEL_DIR="${COMFYUI_DIR}/models"
PORT="${PORT:-8188}"

required_files=(
  "${MODEL_DIR}/diffusion_models/krea2_turbo_fp8_scaled.safetensors"
  "${MODEL_DIR}/text_encoders/qwen3vl_4b_fp8_scaled.safetensors"
  "${MODEL_DIR}/vae/qwen_image_vae.safetensors"
)

missing=0
for file in "${required_files[@]}"; do
  [[ -f "${file}" ]] || missing=1
done

if [[ ! -f "${PROJECT_DIR}/.runtime/dependencies.ready" || "${missing}" == "1" ]]; then
  KREA_MODEL_DIR="${MODEL_DIR}" bash "${PROJECT_DIR}/comfyuiTool/setup-krea2.sh"
fi

cd "${COMFYUI_DIR}"
exec python3 main.py \
  --listen 0.0.0.0 \
  --port "${PORT}"
