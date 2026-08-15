#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_COMFYUI_DIR="/workspace/ComfyUI"

if [[ ! -f "${TEMPLATE_COMFYUI_DIR}/main.py" ]]; then
  echo "This project is configured for CloudStudio's preinstalled ComfyUI GPU template."
  echo "Create/open that template first so /workspace/ComfyUI exists, then run again."
  exit 1
fi

export COMFYUI_DIR="${TEMPLATE_COMFYUI_DIR}"
export DATA_DIR="${PROJECT_DIR}/.data"
export MODEL_PATHS_TEMPLATE="${PROJECT_DIR}/extra_model_paths.yaml"
export PORT="${PORT:-8188}"

if ! command -v hf >/dev/null 2>&1; then
  python3 -m pip install --user --upgrade "huggingface_hub[cli]"
  export PATH="${HOME}/.local/bin:${PATH}"
fi

exec bash "${PROJECT_DIR}/start.sh"
