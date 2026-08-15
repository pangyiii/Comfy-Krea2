#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_COMFYUI_DIR="/workspace/ComfyUI"

if [[ ! -f "${TEMPLATE_COMFYUI_DIR}/main.py" ]]; then
  echo "This project requires CloudStudio's preinstalled ComfyUI GPU template at /workspace/ComfyUI."
  exit 1
fi

export COMFYUI_DIR="${TEMPLATE_COMFYUI_DIR}"
export DATA_DIR="${PROJECT_DIR}/.data"
export MODEL_PATHS_TEMPLATE="${PROJECT_DIR}/extra_model_paths.yaml"
export PORT="${PORT:-8188}"

exec bash "${PROJECT_DIR}/start.sh"
