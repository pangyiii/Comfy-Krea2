# ComfyUI + Krea 2 Turbo FP8（CloudStudio A10）

这是一个可直接从 GitHub 导入 CloudStudio 的完整应用仓库。仓库内已经包含：

- 完整 ComfyUI 源码
- Krea 2 官方源码
- ComfyUI-Manager
- CloudStudio Preview 配置
- Krea 2 Turbo FP8 一次性准备与启动脚本

## CloudStudio 规格

创建新应用时选择：

- **GPU A10**
- 24 GB 显存
- 116 GB 内存
- Preview 端口：8188

本项目不使用 T4，也没有添加 `--lowvram`。

## 一次性准备与启动

从本仓库创建 A10 应用后，先在 CloudStudio 终端执行一次：

```bash
bash /workspace/comfyuiTool/setup-krea2.sh
```

这个阶段只在依赖或模型文件缺失时安装/下载；日志写入
`/workspace/logs/setup-krea2.log`。成功后再点击“运行”。CloudStudio 会读取
`.vscode/preview.yml` 并执行：

```bash
bash comfyuiTool/comfyuiTool.sh
```

日常 Preview 只会校验准备标记与模型文件，然后立即启动真正的 ComfyUI：

```bash
python3 main.py --listen 0.0.0.0 --port 8188
```

它不会安装依赖、下载模型，或用占位 HTTP 页面占用 8188。若准备不完整或 CUDA
不可用，Preview 会立刻退出并在日志中输出下一步命令，避免在 ComfyUI 未运行时持续消耗 A10。

之后准备和启动都会复用现有依赖、模型和 Hugging Face 缓存，不重复下载。

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