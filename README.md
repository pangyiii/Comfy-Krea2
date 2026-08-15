# ComfyUI + Krea 2 Turbo FP8（CloudStudio A10）

这是一个可直接从 GitHub 导入 CloudStudio 的完整应用仓库。仓库内已经包含：

- 完整 ComfyUI 源码
- Krea 2 官方源码
- ComfyUI-Manager
- CloudStudio Preview 配置
- Krea 2 Turbo FP8 自动初始化与启动脚本

## CloudStudio 规格

创建新应用时选择：

- **GPU A10**
- 24 GB 显存
- 116 GB 内存
- Preview 端口：8188

本项目不使用 T4，也没有添加 `--lowvram`。

## 启动

从本仓库创建应用后，点击“运行”。CloudStudio 会读取 `.vscode/preview.yml` 并执行：

```bash
bash comfyuiTool/comfyuiTool.sh
```

首次启动会：

1. 安装/校验 ComfyUI 依赖；
2. 下载 Krea 2 Turbo FP8、Qwen3-VL 文本编码器和 VAE；
3. 启动 ComfyUI。

之后启动会复用现有依赖和模型，不重复下载。

## 模型位置

```text
ComfyUI/models/diffusion_models/krea2_turbo_fp8_scaled.safetensors
ComfyUI/models/text_encoders/qwen3vl_4b_fp8_scaled.safetensors
ComfyUI/models/vae/qwen_image_vae.safetensors
ComfyUI/models/loras/
```

模型权重被 `.gitignore` 排除，只保存在 CloudStudio 应用工作区，不会提交到 GitHub。

## LoRA

进入 ComfyUI 后使用 **Manager → Install Models** 安装 LoRA，或把 `.safetensors` 放入 `ComfyUI/models/loras/`，然后刷新模型列表。

## Krea 2 Turbo 参数

- Steps：8
- CFG：0
- Timestep shift / mu：1.15
- 建议起始分辨率：1024×1024

如 Hugging Face 要求身份验证，在 CloudStudio 环境变量中配置 `HF_TOKEN`，不要写入仓库。
