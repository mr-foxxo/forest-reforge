# Referências dos projetos de origem

[English (default)](../upstream.md) | [Português (Brasil)](upstream.md) | [Índice](README.md)

Pesquisa de compatibilidade registrada em **27/10/2026**. Os links são pontos de entrada oficiais, sem garantia de comportamento de versões futuras. Registre release ou commit exato usado em cada reprodução. Os títulos oficiais foram preservados para facilitar a localização.

## Documentação primária

- [NVIDIA legacy GPU compute capability](https://developer.nvidia.com/cuda/gpus/legacy)
- [NVIDIA vGPU GPU support matrix](https://docs.nvidia.com/vgpu/gpus-supported-by-vgpu.html)
- [NVIDIA vGPU 19 KVM release notes](https://docs.nvidia.com/vgpu/19.0/grid-vgpu-release-notes-generic-linux-kvm/release-notes.html)
- [CUDA architecture transition](https://developer.nvidia.com/blog/navigating-gpu-architecture-support-a-guide-for-nvidia-cuda-developers/)
- [NVIDIA open GPU kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules)
- [Proxmox release history](https://pve.proxmox.com/wiki/Roadmap)
- [Proxmox PCI passthrough](https://pve.proxmox.com/wiki/PCI(e)_Passthrough)
- [vLLM current GPU requirements](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/) and [0.7.3 historical requirements](https://docs.vllm.ai/en/v0.7.3/getting_started/installation/gpu/)
- [llama.cpp build guide](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md)
- [Cilium L2 announcements](https://docs.cilium.io/en/stable/network/l2-announcements/)
- [Cilium Gateway API](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/)
- [Kubeadm HA](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
- [kube-vip static pods](https://kube-vip.io/docs/installation/static/)
- [cert-manager DNS-01](https://cert-manager.io/docs/configuration/acme/dns01/)
- [Cloudflare origin parameters](https://developers.cloudflare.com/tunnel/reference/origin-parameters/)
- [Backstage GitHub auth](https://backstage.io/docs/auth/github/provider/)
- [Backstage GitHub organizational data](https://backstage.io/docs/integrations/github/org/)
- [Argo declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
- [EKS access entries](https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html)
- [VPC peering invalid/transitive configurations](https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html)
- [ECR registry authentication](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html)

## Hardware e reprodução

Use também os manuais exatos do chassis, riser, placa GPU, rack, fonte, UPS e motherboard. Documentação genérica não substitui pinagem ou limites específicos da peça. Preserve atribuição, versão e checksum de entradas externas. Consulte a [matriz de compatibilidade](compatibility.md) e o [registro de stack](examples/validated-stack.md).
