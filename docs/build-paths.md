# Build paths and dependency gates

[English (default)](build-paths.md) | [Português (Brasil)](pt-BR/build-paths.md) | [Documentation index](README.md)

## Choose a scope

| Path | Minimum | Useful result | Limits |
|---|---|---|---|
| Seed | One stable host, DNS/router, backup disk | VM platform and CPU/GPU lab | No physical HA |
| Grove | Multiple hosts, isolated management, off-host backup | Core Kubernetes + GitOps + portal | Quorum and storage require explicit failure-domain design |
| Skybridge | Grove plus AWS accounts and VPN/API routing | Den-managed local + EKS delivery | Cloud costs and network dependencies |

GPU compute is optional for the cluster foundation. Qualify GPUs in isolated guests before putting inference workloads on Kubernetes. AWS is optional for local usefulness.

## Ordered implementation

| Step | Action | Responsible layer | Gate before continuing |
|---|---|---|---|
| 0 | Inventory, site contract, version record | Operator | No overlapping subnets or duplicate IPs |
| 1 | Rack, electrical, airflow, cable labels | Operator | Physical inspection and measured load |
| 2 | RAM/disk/firmware tests | Operator | Repeatable hardware stability |
| 3 | OOB, DNS, OpenWrt zones and VPN | Operator/network configuration | Recovery path and negative access tests |
| 4 | Hypervisor, bridges, backups, VM templates | Proxmox + automation | Restore a disposable VM |
| 5 | One passthrough GPU guest | Operator | Driver and real kernel execute |
| 6 | kubeadm, kube-vip, Cilium, Gateway API | Bootstrap automation | Node/pod/API/VIP network tests |
| 7 | Storage, cert-manager, canonical DNS | Bootstrap automation | Persistence + TLS verification |
| 8 | Argo, metrics, baseline policy, backups | Bootstrap automation | Commit sync and external backup |
| 9 | GitOps handoff, secrets references | Ansible → Argo | No double ownership |
| 10 | Backstage, DB, GitHub identity | App build + GitOps | Internal login and permission tests |
| 11 | Cloudflare Backstage publication | External setup + GitOps | Allowed/denied external users tested |
| 12 | AWS account/role/network setup, EKS registration | Cloud control plane + Argo | Scoped deployment and denial tests |
| 13 | Logging, AI serving, expansion | GitOps + measured experiments | Capacity, recovery and cost evidence |

The historical playbook names remain evidence. The new [automation guide](automation.md) provides generic phased implementations and explains the private inputs and ownership handoff.

## Stop conditions

Stop at unexplained memory errors, disk faults, thermal throttling, an unknown device/power pinout, absent rollback access, overlapping CIDRs, or credentials that are broader than the target task. These are concrete failed prerequisites. Do not build additional layers to hide them.
