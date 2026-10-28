# 07 · Canopy — Kubernetes foundation

## Prerequisites

Stable hardware and VM identity; non-overlapping node/pod/service CIDRs; working time and DNS; routed access; an API VIP reserved outside DHCP; independent recovery. Select exact Kubernetes, containerd, kube-vip, Gateway API CRD and Cilium versions from their mutual support matrices. Archive their values/configurations before upgrade.

The original workflow is described in source notes 10/11. This iteration adds generic `roots`, `canopy` and `paths` phases under `automation/ansible`; use the [automation guide](../docs/automation.md) instead of executing historical source paths.

## Bootstrap sequence

1. Prepare node OS: consistent packages, required kernel modules/sysctls and container runtime. Match kubelet/runtime cgroup configuration. Disable swap for this baseline; a deliberate NodeSwap design would be a separate decision.
2. Install pinned kubeadm/kubelet/kubectl from the selected minor-version repository. Record exact package versions and upgrade policy.
3. Reserve `api.k8s.den.int.example.net → 172.16.3.30`. Prepare a kubeadm config using the API version accepted by the chosen kubeadm, a stable `controlPlaneEndpoint`, and SANs covering intended API names/IPs.
4. Configure encryption at rest before initialization. Distribute the encryption provider file securely to all API servers and include it in protected backups. Encrypting new writes does not automatically rewrite old unencrypted objects.
5. Follow the pinned kube-vip static-pod bootstrap procedure, including its kubeadm-version-specific bootstrap kubeconfig behavior. Use the correct physical interface, not an assumed `eth0`.
6. Initialize the first node without kube-proxy (`--skip-phases=addon/kube-proxy` where supported). Preserve join material privately and remove expired bootstrap credentials.
7. Join additional control planes one at a time; join workers. NotReady before a working CNI is expected. Keep quorum available throughout changes.
8. Install compatible Gateway API CRDs before enabling Cilium's Gateway integration. Install Cilium with explicit API server host/port, kube-proxy replacement and a coherent IPAM/routing model.
9. Validate pod-to-pod across nodes, pod-to-service, DNS and north/south paths. Native routing requires actual routes for pod CIDRs or the chosen Cilium native-routing design; Helm booleans alone cannot supply missing router routes.
10. Enable Hubble and optional Cilium WireGuard encryption after baseline connectivity. Cilium node encryption is distinct from human WireGuard access.
11. Apply LB-IPAM pool and L2 announcement policy after confirming announcing workers have an interface on the VIP L2 network. Scope selectors and interfaces intentionally; size Kubernetes API client rate limits for lease traffic.
12. Create the private Gateway and TLS listeners; add individual HTTPRoutes. Install local storage, metrics and Argo only after the substrate tests pass.

## Values contract, not a complete chart file

```yaml
kubeProxyReplacement: true
k8sServiceHost: 172.16.3.30
k8sServicePort: 6443
l2announcements:
  enabled: true
gatewayAPI:
  enabled: true
```

Complete routing, IPAM, interface and encryption values for your selected Cilium chart. Do not merge this fragment into an unrelated version blindly. The historical `l2NeighDiscovery.enabled` field is not the switch that proves L2 announcement is enabled.

## VIP and Gateway acceptance

```bash
kubectl get nodes -o wide
kubectl get --raw=/readyz
kubectl -n kube-system get ds
kubectl -n kube-system exec ds/cilium -- cilium-dbg config --all
kubectl get ciliumloadbalancerippools,ciliuml2announcementpolicies
kubectl -n kube-system get leases
kubectl get svc -A -o wide
kubectl get gateway,httproute -A
```

No kube-proxy DaemonSet is expected in this design. Inspect the generated LoadBalancer Service's `.status.loadBalancer.ingress`; `.spec.externalIPs` is a different mechanism. A VIP allocation does not prove its advertisement or reachability.

Look for Gateway `Accepted`/`Programmed` and HTTPRoute `Accepted`/`ResolvedRefs` conditions. Allow cross-namespace route attachment deliberately; use ReferenceGrant when required for cross-namespace backend/secret references. Do not fix attachment errors by allowing every namespace indiscriminately.

Cilium documents L2 announcement limitations with `externalTrafficPolicy: Local`; use a configuration supported by the installed release. Verify ARP on the router-facing segment, TCP 443 and TLS from another host and through wg-admin. Test the return path, not just the cluster-local curl.

## Expansion

The screenshots reviewed on 2026-10-28 show **five control planes and eight workers, all Ready at kubelet v1.36.4**. The worker-only dashboard shows 64 CPU and 124.1 GiB allocatable RAM. See the [observed snapshot](../docs/den-case-study.md) for scope and limits; per-node resource sizes and hypervisor placement are not shown. The [observed-size inventory](../automation/ansible/inventory.observed.example.yml) represents this scale with generic identifiers. It is separate from the smaller new-build default.

Derive expected counts from the intended inventory and refresh evidence with [cluster-resources.py](../scripts/cluster-resources.py), rather than treating the screenshot as a universal baseline. Add nodes in stages: prepare OS/network, join, validate Ready/Cilium/storage, label/taint purpose, test a workload, then allow normal scheduling. The two infrastructure-only hypervisors are not extra cluster nodes or capacity.

Do not rename joined nodes in place. Drain with workload/PDB awareness, remove/recreate membership using the chosen procedure, and preserve data ownership. Never drain all control planes or all LocalPV owners together.

References: [Cilium L2](https://docs.cilium.io/en/stable/network/l2-announcements/), [kubeadm HA](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/), [kube-vip static pods](https://kube-vip.io/docs/installation/static/).
