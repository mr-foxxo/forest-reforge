# Den validations and experiments

[English (default)](den-validations-experiments.md) | [Português (Brasil)](pt-BR/den-validations-experiments.md) | [Documentation index](README.md)

The infrastructure dashboard set adds ten views to the seven-image hardware/node baseline. Proxmox graph axes and a node-graph tooltip display **2026-10-28**; Grafana panels use their displayed UTC ranges. Each view has its own scope and sampling instant. The [platform record](den-case-study.md) and [machine-readable profile](../examples/observed-platform.json) retain the baseline and these follow-up observations separately.

Two screenshots have been reviewed for public use and copied **unchanged** into `assets`. The other eight contain account details, infrastructure addresses, private FQDNs, host aliases or sign-in overlays and remain in private reference storage. Original hashes and alias mapping are recorded privately. The [asset manifest](../assets/evidence.json) records the public images and their checksums.

## VM placement and failure domains

The Proxmox guest trees now establish the placement previously left open:

| Generic host | Control planes | Workers | Other guests | Datacenter summary |
|---|---|---|---|---|
| hv01 | core-cp01, core-cp02, core-cp03 | core-wk01 through core-wk04 | One running management VM; one template | One online standalone Proxmox node, eight running VMs |
| hv02 | core-cp04, core-cp05 | core-wk05 through core-wk08 | One template | One online standalone Proxmox node, six running VMs |
| hv03, hv04 | None | None | Integrated infrastructure; individual workloads outside these views | Excluded from Kubernetes host capacity |

Both datacenter views explicitly say **standalone node – no cluster defined**. The Kubernetes cluster spans independent Proxmox hosts; these panels do not describe a Proxmox HA cluster. Templates are not running Kubernetes nodes. Guest IDs are local to each hypervisor and are retained privately, while public documentation uses role-based guest names.

For a **stacked-etcd model with five voting members**, the observed three/two control-plane split has an asymmetric failure budget. Loss of hv01 leaves two voters, below the required majority of three; loss of hv02 leaves three. This is a topology calculation, conditional on actual etcd membership, rather than a completed outage test. Verify membership and place voters across a third independent host before claiming tolerance of either physical host's loss. The infrastructure-only hosts do not become voters automatically.

The datacenter storage gauges show **1.44/3.38 TiB used/total on hv01** and **1.07/3.24 TiB on hv02**. These are Proxmox UI aggregates, distinct from the approximately 94 GiB root filesystems in the host panels. Storage entries can include shared or duplicate backing capacity; do not sum these gauges into a unique physical-disk or backup-capacity claim.

## Monitoring and cluster resources

![Cluster CPU and memory usage, request commitment and limit commitment, with namespace resource series](../assets/cluster_resources.png)

*Public evidence: Kubernetes / Compute Resources / Cluster, Last one hour UTC. This is a cluster dashboard, separate from the earlier worker-filtered overview.*

| Displayed panel | Value |
|---|---|
| CPU utilization | 6.15% |
| CPU requests commitment | 13.5% |
| CPU limits commitment | 52.2% |
| Memory utilization | 18.4% |
| Memory requests commitment | 17.0% |
| Memory limits commitment | 59.3% |

Visible namespace series include Argo CD, Backstage, cert-manager and Cilium experiment namespaces. The quota table shows **18 pods / 6 workloads in monitoring** and **6 pods / 3 workloads in cert-manager**. The dashboard demonstrates collected workload metrics and resource visibility; chart versions, alert delivery and backend configuration remain separate records.

The six-hour node overview additionally shows memory requests of **27.7 GiB** and memory usage of **40.9 GiB**. Its allocatable legend is partly clipped, so that value is not transcribed. CPU/memory percentages are visible for individual nodes, including a last CPU value of 13.6% on core-wk02 and a last memory value of 45.2% on core-wk05. These establish workload variation, not equal per-node allocations or a saturation benchmark.

Dashboard percentages, per-node memory usage and the earlier worker-only totals have different scopes/queries and capture instants. Do not combine them to infer a new whole-cluster capacity or a free-memory guarantee. Reproduce the query, selected filters, time range and units when comparing an experiment.

## Selected control-plane resources

The Node (Pods) dashboard selects **core-cp01** and displays:

| Resource | Capacity | Allocatable |
|---|---|---|
| CPU | 2 cores | 2 cores |
| Memory | 7.76 GiB | 7.66 GiB |

This is now a measured per-node record for one control plane. It does not establish identical sizes for the other twelve nodes. Cilium, Cilium Envoy, etcd, kube-controller-manager and node-feature-discovery component names appear in the selected node's metric series/table.

## Argo CD runtime

![Argo CD workload CPU and memory metrics, with running Pod counts](../assets/workloads.png)

*Public evidence: Kubernetes / Compute Resources / Namespace (Workloads), namespace `argocd`, Last one hour UTC.*

| Visible workload row | Type | Running pods |
|---|---|---|
| argocd-server | Deployment | 2 |
| argocd-applicationset-controller | Deployment | 2 |
| argocd-redis | Deployment | 1 |
| argocd-dex-server | Deployment | 1 |
| argocd-application-controller | StatefulSet | 1 |

The repo-server also has visible CPU/memory series, but its running-pod row is outside the visible table. Record its presence without inventing a replica count. The evidence establishes runtime component activity and resource monitoring. Application sync, destination authorization, OAuth sign-in/rejection and cross-account delivery each require their corresponding functional result. The visible single Redis/controller instances and the two-host substrate must be considered when describing availability.

## Experiment ledger

| Area | Recorded result | Next reproducible experiment |
|---|---|---|
| Hypervisor placement | All thirteen Kubernetes guests mapped to two standalone hosts | Reconcile VM configuration and etcd membership, then test one host failure in a recovery-backed maintenance window |
| Metrics | Cluster, namespace and selected-node dashboards contain resource series | Save query/filter/time metadata; run a bounded disposable workload and compare before/during/after readings |
| Argo CD | Component CPU/memory series and five visible running-pod counts | Sync a disposable application in an allowed namespace and prove a forbidden destination is rejected |
| Backstage / certificates | Namespace CPU/memory series are present; cert-manager workload rows are visible | Record catalog sign-in and rejection, then certificate issuance/renewal and trusted-route checks |
| Cilium policy tests | `cilium-test-1`, `cilium-test-ccnp1` and `cilium-test-ccnp2` have metric series | Preserve the actual connectivity/policy test report and positive/denied paths; namespace existence is not its verdict |
| GPU discovery | Master/worker node-feature-discovery metrics appear in the selected control-plane view | Inspect intended GPU-node PCI identity, labels and allocatable device resources, then run a small CUDA operation and the chosen model |

Node-feature-discovery components are evidence of the discovery layer, not a driver, device-plugin allocation, licensed vGPU profile or CUDA/model success. Keep the [GPU stack record](../examples/validated-stack.md) tied to the exact host/guest/toolchain/workload tuple. Use [acceptance.md](acceptance.md) for functional gates and [the operations module](../modules/12-lookout-operations.md) for ongoing collection and recovery.
