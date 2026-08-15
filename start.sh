#!/usr/bin/env bash
set -Eeuo pipefail

COMFYUI_DIR="${COMFYUI_DIR:-/opt/ComfyUI}"
DATA_DIR="${DATA_DIR:-/data}"
MODEL_DIR="${DATA_DIR}/models"
OUTPUT_DIR="${DATA_DIR}/output"
PORT="${PORT:-8188}"
MODEL_PATHS_TEMPLATE="${MODEL_PATHS_TEMPLATE:-${COMFYUI_DIR}/extra_model_paths.yaml}"
MODEL_PATHS_CONFIG="${DATA_DIR}/extra_model_paths.yaml"

mkdir -p "${MODEL_DIR}/diffusion_models" "${MODEL_DIR}/text_encoders" "${MODEL_DIR}/vae" "${MODEL_DIR}/loras" "${OUTPUT_DIR}" "${DATA_DIR}/user"
sed "s|/data|${DATA_DIR}|g" "${MODEL_PATHS_TEMPLATE}" > "${MODEL_PATHS_CONFIG}"

required_files=(
  "diffusion_models/krea2_turbo_fp8_scaled.safetensors"
  "text_encoders/qwen3vl_4b_fp8_scaled.safetensors"
  "vae/qwen_image_vae.safetensors"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "${MODEL_DIR}/${file}" ]]; then
    echo "Krea 2 model files are not ready. Run comfyuiTool/setup-krea2.sh once on a CPU workspace, then restart."
    break
  fi
done

cd "${COMFYUI_DIR}"
exec python3 main.py \
  --listen 0.0.0.0 \
  --port "${PORT}" \
  --user-directory "${DATA_DIR}/user" \
  --output-directory "${OUTPUT_DIR}" \
  --extra-model-paths-config "${MODEL_PATHS_CONFIG}"
