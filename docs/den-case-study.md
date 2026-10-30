# The Den: observed platform

[English (default)](den-case-study.md) | [Português (Brasil)](pt-BR/den-case-study.md) | [Documentation index](README.md)

Reviewed **2026-10-28** from the initial seven-image baseline and ten follow-up infrastructure views, plus the owner's clarification of infrastructure membership. The baseline images lack an absolute capture time; follow-up graph axes display 2026-10-28. Hardware/software values below retain their source-view scope. Role-based IDs replace private hostnames. Two clean dashboard originals are versioned under [assets](../assets/README.md); private views and alias/hash provenance remain local.

The follow-up [validations and experiment ledger](den-validations-experiments.md) adds observed VM placement, standalone Proxmox topology, cluster/namespace metrics, a selected control-plane resource view, and Argo CD workload counts with public screenshots.

The **2026-10-30 operator inventory review** adds platform identities, per-VM declared allocations and infrastructure entries. See [Den inventory and resource allocations](den-inventory.md) for all thirteen VM rows and their totals. Inventory declarations and the older dashboard measurements retain separate provenance and units.

## Physical infrastructure

CPU counts are **logical processors**, not physical cores. Memory values are the displayed usable totals, not DIMM label capacities. Root-disk sizes below describe `/` only, not all VM datastores or attached disks.

| Generic host | Platform in inventory | CPU shown | Sockets / logical CPU | Usable RAM | Proxmox manager | Running kernel | Boot | Kubernetes guest host |
|---|---|---|---|---|---|---|---|---|
| hv01 | Dell PowerEdge R710 | Xeon X5690 @ 3.47 GHz | 2 / 24 | 125.87 GiB | 9.2.4 | 7.0.14-5-pve | Legacy BIOS | Yes |
| hv02 | Dual-socket X99 | Xeon E5-2698 v3 @ 2.30 GHz | 2 / 64 | 62.65 GiB | 9.2.18 | 7.0.14-16-pve | EFI | Yes |
| hv03 | Dell PowerEdge T310 | Xeon X3430 @ 2.40 GHz | 1 / 4 | 15.61 GiB | 9.2.2 | 7.0.2-6-pve | Legacy BIOS | No; integrated infrastructure |
| hv04 | Dell PowerEdge T410 | Xeon X5660 @ 2.80 GHz | 1 / 12 | 23.46 GiB | 9.2.2 | 7.0.2-6-pve | Legacy BIOS | No; integrated infrastructure |

The two Kubernetes guest hosts expose **88 logical CPU and 188.52 GiB usable RAM combined**. The other two hypervisors remain infrastructure members and are excluded from Kubernetes host-capacity accounting. They are not silently added to `canopy` or treated as spare cluster failure domains. The screenshots do not identify their individual service workloads.

At the displayed instant, hv01 used 75.49/125.87 GiB RAM and hv02 used 50.34/62.65 GiB, with 8.95 GiB KSM sharing on hv02. The corresponding unused host RAM was approximately 50.38 and 12.31 GiB. These are host-wide usage observations, not guest reservations or available capacity for a new VM. Hypervisor OS/cache, other guests, shared pages and overcommit must be accounted for separately. The root filesystems showed about 93.93 GiB each (93.94 GiB on hv04); that is not evidence of total storage capacity.

Platform names in this table come from the current operator inventory; CPU/RAM/kernel/boot values come from the earlier panels. The inventory places a Tesla V100 note on core-wk05, while P4 history remains in its dedicated runbook. Neither the platform names nor the displayed 7.x kernels establish driver/module, vGPU or CUDA results. The older 196 GB RAM description is superseded for physical-host sizing by the displayed totals, independently of declared guest RAM values.

## NAS observation

The operator inventory identifies `nas01` as a **Dell PowerEdge 2950**. Its earlier dashboard displays **TrueNAS Community 25.10.7 – Goldeye**, an **Xeon E5410 @ 2.33 GHz**, and **23.5 GiB available ECC memory**. Eight CPU chart series are visible; the panel does not establish socket count. The platform description and measured/dashboard state are recorded as complementary sources.

| Generic pool | Displayed status | Data vdevs / disks | Disk errors | Used | Free space |
|---|---|---|---|---|---|
| pool01 | ONLINE | 1 / 1 | 0 of 1 | 17.72% | 465.61 GiB |
| pool02 | ONLINE | 1 / 1 | 0 of 1 | 0.00% | 1.76 TiB |

The last-scrub indicators are green. No scrub timestamp, full `zpool status`, mirror/RAID layout, NFS/SMB/iSCSI export, Kubernetes mount, backup execution or restore result is supplied. These single-disk pool views do not establish disk redundancy, replicated Kubernetes storage or an off-host restore path. Do not present the NAS as a validated replacement for LocalPV or a completed backup destination.

## Kubernetes observation

The node list shows **13 Ready nodes**, all displaying **kubelet v1.36.4**:

| Node set | Count | Displayed Ready | Displayed taints per node |
|---|---|---|---|
| core-cp01 through core-cp05 | 5 control planes | 5 | 1 |
| core-wk01 through core-wk08 | 8 workers | 8 | 0 |

The taint key/effect is not visible, and node age is not uptime. The Proxmox views and current inventory agree on placement: **hv01 hosts core-cp01–03 and core-wk01–04; hv02 hosts core-cp04–05 and core-wk05–08**. Both hosts display standalone Proxmox datacenters. The selected core-cp01 metrics view shows 2 CPU capacity/allocatable and 7.76/7.66 GiB memory capacity/allocatable. The inventory now lists every VM's declared vCPU/RAM values, including **4 vCPU on core-cp04–05**; exact Node API quantities for the other twelve remain a separate measurement task.

For five stacked-etcd voters, this three/two split requires three remaining voters. Loss of hv01 would leave two, while loss of hv02 would leave three. Verify actual etcd membership and perform controlled recovery-backed tests; the [experiment ledger](den-validations-experiments.md#vm-placement-and-failure-domains) records this conditional topology analysis separately from a completed failure test.

The resource dashboard is explicitly filtered to **Worker Nodes**. It reports:

| Worker resource | Usage | Requests | Limits | Allocatable | Capacity |
|---|---|---|---|---|---|
| CPU (cores) | 1.45 | 7.88 | 49.85 | 64.00 | 64.00 |
| Memory (GiB) | 17.2 | 29.0 | 99.0 | 124.1 | 124.9 |
| Pods | 116 | Not shown | Not shown | 880 | 880 |

At that instant, aggregate requests left **56.12 CPU and about 95.1 GiB worker allocatable memory unrequested**. Pod slots had 764 unused positions. These are arithmetic differences of rounded dashboard totals, not a scheduling guarantee. Placement fragmentation, taints, affinities, quotas, daemon overhead, LocalPV ownership and failure reserves still matter. CPU/memory usage is an instantaneous dashboard metric, not a load test. The 116-pod value is worker-scoped; no complete cluster-wide pod count or control-plane resource total is supplied. Do not distribute the aggregates evenly across nodes or add host RAM to guest allocatable RAM.

The current inventory declares **14 control-plane and 64 worker vCPUs**, totaling **78 vCPUs** across the thirteen Kubernetes VMs. Its RAM column totals **40 + 152 = 192**, with no unit stated. These declared values do not replace the worker dashboard's 124.9 GiB capacity / 124.1 GiB allocatable reading. Reconcile current VM memory units/configuration and Node exports using the [inventory guide](den-inventory.md#reconcile-inventory-and-measured-resources).

## What can be marked observed

| Claim | Current evidence | Remaining gate |
|---|---|---|
| Four hypervisors exist with the displayed CPU/RAM/versions | Host summary screenshots | Export exact packages, datastore/guest inventory, headers and driver state |
| Two hypervisors host Kubernetes; two are infrastructure only | Owner clarification and follow-up Proxmox guest trees; thirteen guests mapped | Verify etcd membership and test the observed three/two voter failure budget |
| NAS dashboard and two pools are online | TrueNAS dashboard | Export/permission checks, scrub details, backup and isolated restore |
| Five control planes and eight workers report Ready at v1.36.4 | Kubernetes node list | API server/etcd/runtime versions, DNS/CNI paths, storage and failure tests |
| Worker resource totals and usage are visible | Worker-filtered dashboard; follow-up cluster/namespace views | Preserve separate query scopes, refresh exact quantities and run bounded load tests |
| Argo and discovery components have runtime metrics | Public Argo workload screenshot and private selected-node view | Record application sync/authorization and GPU device/CUDA results separately |
| Generic automation can reproduce the running environment | Not established by these images | Run the new implementation on a disposable target with a complete pinned contract |

The [machine-readable observation](../examples/observed-platform.json) preserves these facts without operational identifiers. The [observed-size inventory](../automation/ansible/inventory.observed.example.yml) models all four hypervisors, the NAS, five control planes and eight workers with documentation addresses. Its `reforge_hypervisor` fields now record the observed guest placement as metadata; they do not migrate or provision VMs. The smaller default inventory remains a separate new-build example.

## Refresh the evidence before use

Use the controller environment from the [automation guide](automation.md). For an existing cluster, start with read-only collection; do not rerun new-build bootstrap to validate screenshots.

```bash
python scripts/cluster-resources.py --context YOUR_PRIVATE_CONTEXT \
  --expect examples/observed-platform.json

# Alternatively, export privately and analyze offline:
umask 077
kubectl --context YOUR_PRIVATE_CONTEXT get nodes -o json > local/nodes.json
python scripts/cluster-resources.py --nodes-json local/nodes.json \
  --expect examples/observed-platform.json
```

The helper emits aggregate role counts, Ready state, kubelet versions and CPU/memory/pod capacity without node names, addresses, annotations or credentials. It performs no writes to Kubernetes and does not read Secrets or Pod specs. Exit 0 means the requested inventory/resource checks passed; 1 means a health/snapshot difference; 2 means collection/input failure. A deliberate later upgrade can differ from this snapshot without being a defect. For another installation, supply your own reviewed profile or omit `--expect`.

The Node API cannot refresh dashboard usage/requests/limits; collect those separately and record scope/query/time. Use the observed placement and actual etcd membership when planning capacity or maintenance. The [experiment ledger](den-validations-experiments.md) links collected metrics to the next bounded workload, GitOps, GPU and failure-domain exercises. Complete the corresponding [acceptance checks](acceptance.md) and retain their results alongside the hardware and runtime evidence.
