# The den: source-reported case study

The originating project combines reused enterprise hardware with a modern platform design. This page preserves its character without publishing operational account IDs or domains.

| Resource | Reported role | Confidence / qualification |
|---|---|---|
| Deerly | R710 rev II, dual X5690, P4, iDRAC6 | Owner reported CPU upgrade, slot detection and host driver milestone |
| Foxy | Dual-socket X99, V100 | Reported; RAM population was under investigation |
| Wolfy | PowerEdge 2950, NAS role in inventory | Inventory entry, not verified current service |
| gw01 | BPi R3 OpenWrt, separate physical zones | Consistent later network map |
| dns01 | RPi4, independent DNS at example .5.53 | Consistent infrastructure dependency |
| P4 ×2 | One installed, second available | Chat reported |
| M40 | Available but unused | No installed workload evidence |
| Synology | DS220j and a three-drive inventory mentioned | Physical drive placement/extra unit is unresolved; do not infer three internal bays |

An older document describes Solis with dual E5-2698 v3 and 196 GB RAM. Later summaries describe different RAM totals for Foxy. These should not be merged into a single asserted machine specification.

## Lessons retained

- Physical segmentation replaced a more complicated VLAN-trunk plan.
- Naming and TLS were corrected before adding more application callbacks.
- A LoadBalancer VIP allocated by Kubernetes was not necessarily reachable over WireGuard.
- Cilium kube-proxy replacement explained the intentional absence of kube-proxy.
- RAM failures had to be isolated by stick, slot, channel and population rather than guessed from a single bad run.
- Proxmox kernel upgrades and old vGPU support moved at different speeds.
- Host driver/service success was distinct from guest licensing and workload success.
- Cloudflared probe configuration and duplicate GitOps manifests could cause restarts even after tunnel registration.
- Argo AWS credential errors could masquerade as helper timeouts.
- Static ECR pull credentials had an expiry lifecycle that initial deployment did not solve.
- Three control planes sharing one physical host did not provide host-level availability.

## Missing evidence to collect next

Exact rack drawing and build photos; power/thermal measurements; definitive current CPU/RAM/GPU inventory; current node subnet; exact running kernel/applied patch for the now-identified 16.14 host procedure; actual successful guest inference; off-cluster restore results; complete AWS account/OU/route inventory; selected secrets backend and logging retention.

The public project is useful before these gaps close because it distinguishes an engineering procedure from a claim that the original site already completed it.
