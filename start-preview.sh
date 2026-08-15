#!/usr/bin/env bash
set -Eeuo pipefail

WORKSPACE_DIR="$(pwd)"
RUNTIME_DIR="${WORKSPACE_DIR}/.runtime"
VENV_DIR="${RUNTIME_DIR}/venv"
COMFYUI_DIR="${RUNTIME_DIR}/ComfyUI"
DATA_DIR="${WORKSPACE_DIR}/.data"

mkdir -p "${RUNTIME_DIR}" "${DATA_DIR}"

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
export DATA_DIR
export PORT="${PORT:-8188}"

exec bash "${WORKSPACE_DIR}/start.sh"
