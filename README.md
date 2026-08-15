# ComfyUI + Krea 2 Turbo FP8 on CloudStudio

This repository is optimised for **CloudStudio's preinstalled ComfyUI GPU template**. It deliberately keeps package installation and model downloads out of the GPU startup path.

## Cost-efficient workflow

1. Create/open the CloudStudio ComfyUI template, which provides `/workspace/ComfyUI`.
2. Use a low-cost CPU specification with the same persistent workspace/disk, then run once:

   ```bash
   bash comfyuiTool/setup-krea2.sh
   ```

   This downloads Krea 2 Turbo FP8 and installs ComfyUI-Manager. It does **not** require a GPU.
3. Switch the same workspace to **GPU A10**.
4. Open Preview. It starts ComfyUI immediately on port 8188 and performs no package or model download.

Do not use GPU T4 for normal Krea 2 operation; 16 GB VRAM is too constrained. A10's 24 GB VRAM is the preferred baseline.

## Persistent locations

- Models and LoRAs: `.data/models`
- Output images: `.data/output`
- Manager: `/workspace/ComfyUI/custom_nodes/comfyui-manager`

## LoRAs

After the one-time setup, open **Manager → Install Models** in ComfyUI. LoRAs are downloaded into the persistent model path. Restart ComfyUI when Manager asks.

## Turbo settings

- Steps: **8**
- CFG: **0**
- Timestep shift / `mu`: **1.15**
- Start at 1024×1024
