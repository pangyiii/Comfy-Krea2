# ComfyUI + Krea 2 Turbo FP8 on CloudStudio

A Docker deployment for ComfyUI with **Krea 2 Turbo FP8**. It downloads the models on first launch to the persistent disk; model weights and credentials are never committed to this repository.

## CloudStudio configuration

| Item | Recommended value |
| --- | --- |
| Compute | **GPU A10** (24 GB VRAM) |
| Persistent disk | 100 GB recommended; 50 GB minimum |
| Persistent mount path | `/data` |
| Build method | Dockerfile |
| Container/service port | `8188` |

Do not use GPU T4 for normal Krea 2 operation: 16 GB VRAM is too constrained. GPU A10 provides the 24 GB VRAM baseline needed for a stable Turbo FP8 deployment.

## Deploy

1. Create a CloudStudio app from this repository.
2. Choose **GPU A10**, add a persistent disk, and mount it at `/data`.
3. Use the repository Dockerfile; leave the start command empty.
4. Expose container port `8188`.
5. If Hugging Face asks for authentication, add `HF_TOKEN` in CloudStudio's secret settings. Do not store it in GitHub.
6. Deploy. The first boot downloads the model into `/data/models`; subsequent boots reuse it.

## Installed models

The startup script downloads these current ComfyUI-compatible assets from `Comfy-Org/Krea-2`:

- `krea2_turbo_fp8_scaled.safetensors`
- `qwen3vl_4b_fp8_scaled.safetensors`
- `qwen_image_vae.safetensors`

## Generation settings

Krea's official recommendation for Turbo is:

- Steps: **8**
- CFG: **0**
- Timestep shift / `mu`: **1.15**
- Output: 1024–2048 px (start with 1024×1024)

The ComfyUI server listens on `0.0.0.0:8188`. Protect the application with CloudStudio authentication or network access control before sharing it publicly.
