#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMFYUI_DIR="${PROJECT_DIR}/ComfyUI"
MODEL_DIR="${COMFYUI_DIR}/models"
RUNTIME_DIR="${PROJECT_DIR}/.runtime"
PORT="${PORT:-8188}"

source "${PROJECT_DIR}/comfyuiTool/require-a10.sh"

required_files=(
  "${MODEL_DIR}/diffusion_models/krea2_turbo_fp8_scaled.safetensors"
  "${MODEL_DIR}/text_encoders/qwen3vl_4b_fp8_scaled.safetensors"
  "${MODEL_DIR}/vae/qwen_image_vae.safetensors"
)

missing_files=()
for file in "${required_files[@]}"; do
  [[ -s "${file}" ]] || missing_files+=("${file}")
done

fail() {
  printf 'ComfyUI preview was not started: %s\n' "$*" >&2
  printf 'Run once in the CloudStudio A10 terminal: bash /workspace/comfyuiTool/setup-krea2.sh\n' >&2
  printf 'After it succeeds, start Preview again. Setup logs: /workspace/logs/setup-krea2.log\n' >&2
  exit 1
}

# Preview is deliberately a runtime-only entrypoint. Do not install packages,
# download weights, or serve a placeholder page here: doing so hides failures
# and keeps an A10 allocated while ComfyUI is not running.
[[ -f "${COMFYUI_DIR}/main.py" ]] || fail "missing ${COMFYUI_DIR}/main.py"
[[ -f "${RUNTIME_DIR}/dependencies.ready" ]] || fail "dependencies are not prepared"
if (( ${#missing_files[@]} > 0 )); then
  printf 'Missing Krea 2 model files:\n' >&2
  printf '  %s\n' "${missing_files[@]}" >&2
  fail "run the one-time setup and wait for it to finish successfully"
fi

python3 -c 'import torch; assert torch.cuda.is_available(), "CUDA is unavailable"' \
  || fail "PyTorch cannot access CUDA; this application requires a GPU A10"

cd "${COMFYUI_DIR}"
exec python3 main.py \
  --listen 0.0.0.0 \
  --port "${PORT}"