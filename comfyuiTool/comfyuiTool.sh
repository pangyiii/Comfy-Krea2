#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMFYUI_DIR="${PROJECT_DIR}/ComfyUI"
MODEL_DIR="${COMFYUI_DIR}/models"
RUNTIME_DIR="${PROJECT_DIR}/.runtime"
STATUS_DIR="${RUNTIME_DIR}/status"
LOG_DIR="${PROJECT_DIR}/logs"
SETUP_LOG="${LOG_DIR}/setup-krea2.log"
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

if [[ ! -f "${RUNTIME_DIR}/dependencies.ready" || "${missing}" == "1" ]]; then
  mkdir -p "${STATUS_DIR}" "${LOG_DIR}"
  cp "${PROJECT_DIR}/comfyuiTool/status/index.html" "${STATUS_DIR}/index.html"
  printf '%s\n' "正在初始化 ComfyUI 与 Krea 2 Turbo FP8。模型较大，请勿重复点击运行。" > "${STATUS_DIR}/status.txt"

  python3 -m http.server "${PORT}" --bind 0.0.0.0 --directory "${STATUS_DIR}" > "${LOG_DIR}/bootstrap-http.log" 2>&1 &
  status_pid=$!

  if KREA_MODEL_DIR="${MODEL_DIR}" bash "${PROJECT_DIR}/comfyuiTool/setup-krea2.sh" > "${SETUP_LOG}" 2>&1; then
    printf '%s\n' "READY：初始化完成，正在切换到 ComfyUI……" > "${STATUS_DIR}/status.txt"
    sleep 2
    kill "${status_pid}" 2>/dev/null || true
    wait "${status_pid}" 2>/dev/null || true
  else
    printf '%s\n' "FAILED：初始化失败。请在终端查看 logs/setup-krea2.log；服务已保持运行，不会循环重启。" > "${STATUS_DIR}/status.txt"
    wait "${status_pid}"
    exit 1
  fi
fi

cd "${COMFYUI_DIR}"
exec python3 main.py \
  --listen 0.0.0.0 \
  --port "${PORT}"
