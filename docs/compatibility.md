# Legacy GPU compatibility matrix

Checked against the linked primary documentation on **2026-10-27**. These are upstream limits and qualification guidance, not lab benchmark results.

| GPU | Architecture / CUDA CC | Official NVIDIA vGPU branch ceiling | Practical first experiment |
|---|---|---|---|
| Tesla M40 | Maxwell / 5.2 | No officially supported vGPU release | Full passthrough + pinned legacy CUDA application |
| Tesla P4 | Pascal / 6.1 | 16; maintenance end listed July 2026 | Full passthrough; legacy vGPU only as explicit experiment |
| Tesla V100 | Volta / 7.0 | 19 for listed variants | Full passthrough or qualified branch-19 vGPU |

Check the exact V100 variant and host form factor. SXM modules are not ordinary PCIe cards. Confirm actual framebuffer capacity; do not infer the installed V100/M40 memory size from a family name.

## Independent compatibility axes

| Axis | Test | Common false inference |
|---|---|---|
| Chassis | Fit, power pinout, slot/riser rating, airflow | Fits physically → supported |
| Hypervisor | Exact kernel, headers, module API, boot signing | Proxmox major number → kernel compatibility |
| GPU driver | Card support and module flavor | Newest driver → all Tesla generations |
| vGPU | GPU + manager + hypervisor + guest matrix + entitlement | V100 support → P4 support |
| CUDA toolkit | Compiler includes target architecture | `nvidia-smi` CUDA label → installed toolkit |
| Framework binary | Wheel contains correct GPU kernels | Framework imports → GPU execution works |
| Model kernel | Attention/quantization/precision compatibility | VRAM fits → model will run |
| Host CPU | Required x86 instructions | Container → CPU instruction emulation |

CUDA 13 removed offline compilation for architectures below CC 7.5. For these three GPUs, use a suitable pre-13 toolkit (12.9 or earlier) and a compatible application revision. This compiler boundary is distinct from driver runtime support. NVIDIA identifies R580 as the legacy architecture driver path; it is not a blanket endorsement of every OS/package/vGPU combination.

NVIDIA's open kernel modules target Turing and newer. The M40/P4/V100 path requires the appropriate proprietary module, subject to the chosen driver's support matrix.

Current vLLM documentation requires CC 7.5+, so none of these three is a current default vLLM target. Older vLLM 0.7.3 documentation lists CC 7.0+, making a pinned V100 experiment plausible, not universally functional. M40/P4 fall below that older documented floor too.

For llama.cpp, build at a pinned revision with the required CUDA architecture and compatible toolkit; validate the specific model and kernels. PyTorch/Ollama/TensorRT support depends on exact release/build. Do not claim “CUDA supported” means their current wheels/images support these cards.

## Required stack record

GPU SKU + PCI identity + VRAM; chassis/riser; BIOS; Proxmox package; kernel/headers; host driver/patch checksum; guest OS/kernel; guest driver; licensing mode where applicable; CUDA toolkit/runtime; framework revision/build flags; container digest; model hash/quantization; test and thermal results; reboot outcome; rollback.

## Sources

- [NVIDIA legacy compute capabilities](https://developer.nvidia.com/cuda/gpus/legacy)
- [NVIDIA vGPU supported GPUs](https://docs.nvidia.com/vgpu/gpus-supported-by-vgpu.html)
- [CUDA architecture support transition](https://developer.nvidia.com/blog/navigating-gpu-architecture-support-a-guide-for-nvidia-cuda-developers/)
- [NVIDIA open kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules)
- [Current vLLM requirements](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/)
- [Historical vLLM 0.7.3 requirements](https://docs.vllm.ai/en/v0.7.3/getting_started/installation/gpu/)
- [llama.cpp build instructions](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
