# Upstream references

Compatibility research date: 2026-10-27. These links are authoritative entry points, not guarantees that a future version retains today's behavior. Record the exact release or commit used in every reproduction.

## GPU and hypervisor (checked)

- [NVIDIA legacy GPU compute capability](https://developer.nvidia.com/cuda/gpus/legacy) — M40/P4/V100 architecture targets.
- [NVIDIA vGPU GPU support matrix](https://docs.nvidia.com/vgpu/gpus-supported-by-vgpu.html) — branch ceilings and card distinctions.
- [NVIDIA vGPU 19 KVM release notes](https://docs.nvidia.com/vgpu/19.0/grid-vgpu-release-notes-generic-linux-kvm/release-notes.html) — release-specific host/guest support.
- [CUDA architecture transition](https://developer.nvidia.com/blog/navigating-gpu-architecture-support-a-guide-for-nvidia-cuda-developers/) — compiler versus runtime support.
- [NVIDIA open GPU kernel modules](https://github.com/NVIDIA/open-gpu-kernel-modules) — supported architecture family.
- [Proxmox release history](https://pve.proxmox.com/wiki/Roadmap) — 9.1 kernel/vGPU compatibility note.
- [Proxmox PCI passthrough](https://pve.proxmox.com/wiki/PCI(e)_Passthrough) — IOMMU, devices and VM assignment.
- [vLLM current GPU requirements](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/) and [0.7.3 historical requirements](https://docs.vllm.ai/en/v0.7.3/getting_started/installation/gpu/) — different architecture floors.
- [llama.cpp build guide](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md) — CUDA CMake configuration; pin revision.

## Platform integration (checked or referenced for implementation)

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

Hardware assembly must additionally use the exact chassis, riser, GPU-board, rack, PSU, UPS and motherboard manuals. Those exact part-number documents were not supplied and are not substituted with generic pinouts here.
