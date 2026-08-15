#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMFYUI_DIR="${PROJECT_DIR}/ComfyUI"
MODEL_DIR="${COMFYUI_DIR}/models"
RUNTIME_DIR="${PROJECT_DIR}/.runtime"
DEPENDENCY_MARKER="${RUNTIME_DIR}/dependencies.ready"
export KREA_MODEL_REPO="${KREA_MODEL_REPO:-Comfy-Org/Krea-2}"
export KREA_MODEL_DIR="${MODEL_DIR}"
export HF_XET_HIGH_PERFORMANCE="${HF_XET_HIGH_PERFORMANCE:-1}"
LOG_DIR="${PROJECT_DIR}/logs"

[[ -f "${COMFYUI_DIR}/main.py" ]] || { echo "ComfyUI/main.py is missing from the repository."; exit 1; }
source "${PROJECT_DIR}/comfyuiTool/require-a10.sh"
mkdir -p "${RUNTIME_DIR}" "${LOG_DIR}" "${MODEL_DIR}/diffusion_models" "${MODEL_DIR}/text_encoders" "${MODEL_DIR}/vae" "${MODEL_DIR}/loras" "${COMFYUI_DIR}/output"
exec > >(tee -a "${LOG_DIR}/setup-krea2.log") 2>&1

echo "Preparing the CloudStudio A10 workspace at ${PROJECT_DIR}."
echo "Hugging Face Xet high-performance mode: ${HF_XET_HIGH_PERFORMANCE}."

if [[ ! -f "${DEPENDENCY_MARKER}" ]]; then
  echo "[1/2] Preparing ComfyUI dependencies (one time only)..."
  python3 -m pip install -r "${COMFYUI_DIR}/requirements.txt"
  if [[ -f "${COMFYUI_DIR}/custom_nodes/comfyui-manager/requirements.txt" ]]; then
    python3 -m pip install -r "${COMFYUI_DIR}/custom_nodes/comfyui-manager/requirements.txt"
  fi
  python3 -m pip install --upgrade huggingface_hub
  touch "${DEPENDENCY_MARKER}"
fi

echo "[2/2] Ensuring Krea 2 Turbo FP8 model assets are present..."
python3 - <<'PY'
import os
from pathlib import Path
from huggingface_hub import hf_hub_download

repo_id = os.environ.get("KREA_MODEL_REPO", "Comfy-Org/Krea-2")
root = Path(os.environ["KREA_MODEL_DIR"])
files = (
    "diffusion_models/krea2_turbo_fp8_scaled.safetensors",
    "text_encoders/qwen3vl_4b_fp8_scaled.safetensors",
    "vae/qwen_image_vae.safetensors",
)
for filename in files:
    target = root / filename
    if target.is_file():
        print(f"Already present: {target}")
        continue
    target.parent.mkdir(parents=True, exist_ok=True)
    hf_hub_download(
        repo_id=repo_id,
        filename=filename,
        local_dir=str(root),
        token=os.environ.get("HF_TOKEN") or None,
    )
    if not target.is_file() or target.stat().st_size == 0:
        raise RuntimeError(f"Download did not produce a usable file: {target}")
    print(f"Ready: {target} ({target.stat().st_size / 1024**3:.2f} GiB)")
PY

echo "Krea 2 Turbo FP8 is ready."