# Troubleshooting by layer

| Symptom | First evidence | Likely branch | Avoid |
|---|---|---|---|
| Memory errors vary with population | Stick/slot/channel matrix | Training, slot/socket, settings or DIMM fault | Declaring all modules defective |
| GPU missing from PCI enumeration | Riser, power, firmware, actual ID | Hardware detection | Installing five driver versions |
| Driver build fails after reboot/update | Running kernel, matching headers, first build error | Kernel API/compiler/signing | Treating taint as root cause |
| Host driver works, VM fails | VFIO/profile mapping and guest logs | Exposure mode/guest driver | Licensing the host as if it were a guest |
| CUDA visible, model fails | CC, wheel arches, operator traceback | Missing kernels/precision | Assuming `nvidia-smi` proves inference |
| Illegal instruction | CPU flags and binary build | AVX/AVX2 baseline | Blaming the GPU automatically |
| VIP allocated, no response | Service status, lease, ARP, same-L2 interface | Announcement or routing | Installing a second LB controller |
| Gateway works locally, not over VPN | Routes, firewall, return path, MTU | Network boundary | Rebuilding Kubernetes |
| TLS unknown authority/name | Served chain, SNI, hostname, trust | Origin cert/name coverage | Leaving verification disabled |
| DNS-01 challenge stuck | Public authority and challenge target | Wrong solver/credential zone/split DNS | Opening WAN HTTP |
| Tunnel registers but pod restarts | Live args, /ready probe, duplicate objects | Metrics binding/reconciliation | Repeated token rotation |
| Backstage login has no user | Catalog annotation/org sync | Identity mapping | Enabling guest auth |
| Backstage login works, wrong permissions | Group and permission policy | Authorization | Treating edge allow as app admin |
| Argo helper exits 20 | STS identity in runtime context | Bad/expired credentials or timeout | Granting AdministratorAccess |
| STS works, EKS forbidden | Access Entry and namespace RBAC | Cluster authorization | Changing routes |
| Image starts once, later pull fails | ECR token age and scope | Expiry | Mutable latest retries |
| PVC pod cannot move to another node | LocalPV affinity/data location | Expected local storage constraint | Deleting the PVC |

## Cilium VIP incident procedure

1. Confirm the service is type LoadBalancer and has the intended status ingress IP.
2. Inspect LB pool conditions and selector match; ensure the address is unique and reserved.
3. Inspect live Cilium config and L2 policy eligibility. Helm values can differ from applied runtime state.
4. Inspect leases and the selected announcing node. Capture ARP on its correct network interface and on the router-facing segment.
5. If nodes are only on `172.16.4.0/24` but VIP is `172.16.3.200`, resolve that L2 mismatch explicitly.
6. Test TCP/TLS from same-L2 host, then routed LAN, then VPN. Compare firewall counters and return routes at the first failing hop.
7. Only after network reachability works, inspect Gateway listeners/HTTPRoutes/backends.

## Evidence hygiene

Share redacted command outputs and exact versions; omit kubeconfigs, Secret dumps, tunnel tokens, JNLP credentials, serials and WAN endpoints. A minimal reproducer should state what changed and which prior tuple still works.
