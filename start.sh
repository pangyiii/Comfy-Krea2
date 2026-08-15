#!/usr/bin/env bash
set -Eeuo pipefail

COMFYUI_DIR="${COMFYUI_DIR:-/opt/ComfyUI}"
DATA_DIR="${DATA_DIR:-/data}"
MODEL_DIR="${DATA_DIR}/models"
OUTPUT_DIR="${DATA_DIR}/output"
PORT="${PORT:-8188}"
MODEL_REPO="${KREA_MODEL_REPO:-Comfy-Org/Krea-2}"

mkdir -p "${MODEL_DIR}/diffusion_models" "${MODEL_DIR}/text_encoders" "${MODEL_DIR}/vae" "${MODEL_DIR}/loras" "${OUTPUT_DIR}"

required_files=(
  "diffusion_models/krea2_turbo_fp8_scaled.safetensors"
  "text_encoders/qwen3vl_4b_fp8_scaled.safetensors"
  "vae/qwen_image_vae.safetensors"
)

missing=0
for file in "${required_files[@]}"; do
  [[ -f "${MODEL_DIR}/${file}" ]] || missing=1
done

if [[ "${missing}" == "1" ]]; then
  echo "Downloading Krea 2 Turbo FP8 assets into ${MODEL_DIR}..."
  hf download "${MODEL_REPO}" \
    --include "diffusion_models/krea2_turbo_fp8_scaled.safetensors" \
    --include "text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
    --include "vae/qwen_image_vae.safetensors" \
    --local-dir "${MODEL_DIR}"
fi

exec python3 main.py \
  --listen 0.0.0.0 \
  --port "${PORT}" \
  --output-directory "${OUTPUT_DIR}" \
  --extra-model-paths-config extra_model_paths.yaml
