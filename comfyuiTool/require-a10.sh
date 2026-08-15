#!/usr/bin/env bash

# CloudStudio compute is selected outside preview.yml. Refuse to prepare or
# launch on the wrong instance so a CPU/T4 workspace cannot silently burn time.
if ! command -v nvidia-smi >/dev/null 2>&1; then
  printf '%s\n' 'A10 preflight failed: nvidia-smi is unavailable (this is a CPU workspace).' >&2
  printf '%s\n' 'In CloudStudio, click the top-right Compute button and select GPU A10 (24GB).' >&2
  exit 1
fi

gpu_name="$(nvidia-smi --query-gpu=name --format=csv,noheader | sed -n '1p')"
gpu_memory="$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | sed -n '1p' | tr -d '[:space:]')"

case "${gpu_name}" in
  *A10*) ;;
  *)
    printf 'A10 preflight failed: detected %s; GPU A10 (24GB) is required.\n' "${gpu_name:-unknown GPU}" >&2
    exit 1
    ;;
esac

if [[ ! "${gpu_memory}" =~ ^[0-9]+$ ]] || (( gpu_memory < 23000 )); then
  printf 'A10 preflight failed: detected %s MiB VRAM; at least 23000 MiB is required.\n' "${gpu_memory:-unknown}" >&2
  exit 1
fi

printf 'A10 preflight passed: %s, %s MiB VRAM.\n' "${gpu_name}" "${gpu_memory}"
