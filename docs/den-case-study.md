# The Den: observed platform and remaining acceptance

Reviewed **2026-10-28** from seven supplied screenshots and the owner's clarification of infrastructure membership. The images do not establish an absolute capture date, so this is a reviewed snapshot rather than a live inventory. Hardware/software values below are visible observations. Role-based IDs replace private hostnames; raw screenshots and their private alias/hash record stay outside the release.

## Physical infrastructure

CPU counts are **logical processors**, not physical cores. Memory values are the displayed usable totals, not DIMM label capacities. Root-disk sizes below describe `/` only, not all VM datastores or attached disks.

| Generic host | CPU shown | Sockets / logical CPU | Usable RAM | Proxmox manager | Running kernel | Boot | Kubernetes guest host |
|---|---|---|---|---|---|---|---|
| hv01 | Xeon X5690 @ 3.47 GHz | 2 / 24 | 125.87 GiB | 9.2.4 | 7.0.14-5-pve | Legacy BIOS | Yes |
| hv02 | Xeon E5-2698 v3 @ 2.30 GHz | 2 / 64 | 62.65 GiB | 9.2.18 | 7.0.14-16-pve | EFI | Yes |
| hv03 | Xeon X3430 @ 2.40 GHz | 1 / 4 | 15.61 GiB | 9.2.2 | 7.0.2-6-pve | Legacy BIOS | No; integrated infrastructure |
| hv04 | Xeon X5660 @ 2.80 GHz | 1 / 12 | 23.46 GiB | 9.2.2 | 7.0.2-6-pve | Legacy BIOS | No; integrated infrastructure |

The two Kubernetes guest hosts expose **88 logical CPU and 188.52 GiB usable RAM combined**. The other two hypervisors remain infrastructure members and are excluded from Kubernetes host-capacity accounting. They are not silently added to `canopy` or treated as spare cluster failure domains. The screenshots do not identify their individual service workloads.

At the displayed instant, hv01 used 75.49/125.87 GiB RAM and hv02 used 50.34/62.65 GiB, with 8.95 GiB KSM sharing on hv02. The corresponding unused host RAM was approximately 50.38 and 12.31 GiB. These are host-wide usage observations, not guest reservations or available capacity for a new VM. Hypervisor OS/cache, other guests, shared pages and overcommit must be accounted for separately. The root filesystems showed about 93.93 GiB each (93.94 GiB on hv04); that is not evidence of total storage capacity.

The earlier R710/X99/P4/V100 descriptions remain owner-reported context. These summary panels do not enumerate chassis models, DIMMs, installed GPUs, driver modules or guest assignments. In particular, the displayed 7.x host kernels do not prove the older vGPU manager/patch tuple works on them. The older 196 GB RAM description is superseded for current sizing by the displayed totals; it is not merged with hv02's current 62.65 GiB.

## NAS observation

`nas01` displays **TrueNAS Community 25.10.7 – Goldeye**, an **Xeon E5410 @ 2.33 GHz**, and **23.5 GiB available ECC memory**. Eight CPU chart series are visible; the panel does not establish socket count. This updates the earlier inventory-only NAS entry with evidence that its dashboard and storage pools were running.

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

The taint key/effect is not visible, and node age is not uptime. The list shows neither per-node CPU/RAM/disk allocations nor placement across physical hosts. Earlier per-VM sizing and placement remain historical until a fresh private Proxmox VM listing is reconciled with Kubernetes node evidence. Five control-plane nodes do not prove that loss of either physical Kubernetes host preserves etcd quorum.

The resource dashboard is explicitly filtered to **Worker Nodes**. It reports:

| Worker resource | Usage | Requests | Limits | Allocatable | Capacity |
|---|---|---|---|---|---|
| CPU (cores) | 1.45 | 7.88 | 49.85 | 64.00 | 64.00 |
| Memory (GiB) | 17.2 | 29.0 | 99.0 | 124.1 | 124.9 |
| Pods | 116 | Not shown | Not shown | 880 | 880 |

At that instant, aggregate requests left **56.12 CPU and about 95.1 GiB worker allocatable memory unrequested**. Pod slots had 764 unused positions. These are arithmetic differences of rounded dashboard totals, not a scheduling guarantee. Placement fragmentation, taints, affinities, quotas, daemon overhead, LocalPV ownership and failure reserves still matter. CPU/memory usage is an instantaneous dashboard metric, not a load test. The 116-pod value is worker-scoped; no complete cluster-wide pod count or control-plane resource total is supplied. Do not distribute the aggregates evenly across nodes or add host RAM to guest allocatable RAM.

## What can be marked observed

| Claim | Current evidence | Remaining gate |
|---|---|---|
| Four hypervisors exist with the displayed CPU/RAM/versions | Host summary screenshots | Export exact packages, datastore/guest inventory, headers and driver state |
| Two hypervisors host Kubernetes; two are infrastructure only | Owner clarification, consistent with supplied platform scope | Reconcile VM IDs/placement privately; test failure-domain assumptions |
| NAS dashboard and two pools are online | TrueNAS dashboard | Export/permission checks, scrub details, backup and isolated restore |
| Five control planes and eight workers report Ready at v1.36.4 | Kubernetes node list | API server/etcd/runtime versions, DNS/CNI paths, storage and failure tests |
| Worker resource totals and usage are visible | Worker-filtered dashboard | Fresh exact Node quantities, requests/limits provenance and load/placement tests |
| Generic automation can reproduce the running environment | Not established by these images | Run the new implementation on a disposable target with a complete pinned contract |

The new [machine-readable observation](../examples/observed-platform.json) preserves these facts without operational identifiers. The [observed-size example inventory](../automation/ansible/inventory.observed.example.yml) models all four hypervisors, the NAS, five control planes and eight workers with documentation addresses and no invented guest placement. The smaller default inventory remains a separate new-build example.

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

The Node API cannot refresh the screenshot's usage/requests/limits; collect those separately from your chosen metrics source and record its scope/query/time. Reconcile hypervisor VM placement privately before claiming host-resilient quorum or scheduling more workloads. Then complete the [acceptance matrix](acceptance.md), especially GPU workload, network/identity rejection, independent data restore and controlled failover. Hardware, pool and Node observations close inventory gaps; they do not close those functional gates.
