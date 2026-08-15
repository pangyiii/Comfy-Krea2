#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE_DIR="$(pwd)"
RUNTIME_DIR="${WORKSPACE_DIR}/.runtime"
DATA_DIR="${WORKSPACE_DIR}/.data"
TEMPLATE_COMFYUI_DIR="/workspace/ComfyUI"

mkdir -p "${RUNTIME_DIR}" "${DATA_DIR}"

# CloudStudio's ComfyUI GPU template already provides this directory.
# Use it directly so reopening a template workspace does not reinstall ComfyUI.
if [[ -d "${TEMPLATE_COMFYUI_DIR}" ]]; then
  echo "Using the ComfyUI installation provided by the CloudStudio template."
  export COMFYUI_DIR="${TEMPLATE_COMFYUI_DIR}"
  if ! command -v hf >/dev/null 2>&1; then
    python3 -m pip install --user --upgrade "huggingface_hub[cli]"
    export PATH="${HOME}/.local/bin:${PATH}"
  fi
else
  VENV_DIR="${RUNTIME_DIR}/venv"
  COMFYUI_DIR="${RUNTIME_DIR}/ComfyUI"

  if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
    python3 -m venv "${VENV_DIR}"
  fi
  source "${VENV_DIR}/bin/activate"

  if [[ ! -d "${COMFYUI_DIR}/.git" ]]; then
    echo "Preparing ComfyUI for the CloudStudio workspace..."
    git clone --depth 1 https://github.com/Comfy-Org/ComfyUI.git "${COMFYUI_DIR}"
  fi

  if [[ ! -f "${RUNTIME_DIR}/.dependencies-installed" ]]; then
    python -m pip install --upgrade pip
    python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
    python -m pip install -r "${COMFYUI_DIR}/requirements.txt"
    python -m pip install --upgrade "huggingface_hub[cli]"
    touch "${RUNTIME_DIR}/.dependencies-installed"
  fi
  export COMFYUI_DIR
fi

export DATA_DIR
export PORT="${PORT:-8188}"

exec bash "${WORKSPACE_DIR}/start.sh"
