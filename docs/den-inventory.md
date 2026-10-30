# Den inventory and resource allocations

[English (default)](den-inventory.md) | [Português (Brasil)](pt-BR/den-inventory.md) | [Documentation index](README.md)

The current operator-maintained inventory was reviewed on **2026-10-30**. It supplements the [platform screenshots](den-case-study.md) and [validation/experiment records](den-validations-experiments.md). Public IDs below follow the project naming convention; actual aliases, addresses and the original inventory remain private. [observed-platform.json](../examples/observed-platform.json) stores the shared structured record for both documentation languages.

## Infrastructure membership

| Public ID | Inventory platform or role | Kubernetes scope |
|---|---|---|
| gw01 | Banana Pi R3 gateway/firewall, Boundary zone | Network infrastructure |
| dns01 | Raspberry Pi 4 infrastructure, Infra zone | Independent network/compute infrastructure |
| hv01 | Dell PowerEdge R710 | Hosts core-cp01–03 and core-wk01–04 |
| hv02 | Dual-socket X99 / V100 host | Hosts core-cp04–05 and core-wk05–08 |
| hv03 | Dell PowerEdge T310 | Integrated infrastructure; no Kubernetes nodes hosted |
| hv04 | Dell PowerEdge T410 | Integrated infrastructure; no Kubernetes nodes hosted |
| nas01 | Dell PowerEdge 2950 | Independent NAS infrastructure |
| mgmt.hv01 | IPMI management for hv01 | OOB infrastructure |
| mgmt.hv02 | IPMI/KVM management for hv02 | OOB infrastructure |
| mgmt01 | Separate management entry | Type, parent, zone and resources are blank in this inventory |

The T310 and T410 descriptions resolve the platform names for the two infrastructure-only hypervisors; they do not add Kubernetes capacity or etcd voters. The NAS description complements its earlier TrueNAS dashboard record. The separate management entry is retained without filling in missing fields from assumptions. Earlier screenshots record a management VM on hv01 as a separate observation.

## Declared Kubernetes VM allocations

The inventory labels its columns **vCPU** and **RAM**. It does **not** state the RAM unit. The values below are preserved as listed; no GB/GiB conversion or current scheduler capacity is implied.

| Node | Hypervisor | vCPU | RAM value (unit unspecified) | Inventory note |
|---|---|---|---|---|
| core-cp01 | hv01 | 2 | 8 | |
| core-cp02 | hv01 | 2 | 8 | |
| core-cp03 | hv01 | 2 | 8 | |
| core-cp04 | hv02 | 4 | 8 | |
| core-cp05 | hv02 | 4 | 8 | |
| core-wk01 | hv01 | 4 | 24 | |
| core-wk02 | hv01 | 4 | 24 | |
| core-wk03 | hv01 | 4 | 16 | |
| core-wk04 | hv01 | 4 | 16 | |
| core-wk05 | hv02 | 16 | 24 | Tesla V100 |
| core-wk06 | hv02 | 8 | 16 | |
| core-wk07 | hv02 | 16 | 24 | |
| core-wk08 | hv02 | 8 | 8 | |

| Scope | VMs | Declared vCPU total | Sum of RAM values (unit unspecified) |
|---|---|---|---|
| Control planes | 5 | 14 | 40 |
| Workers | 8 | 64 | 152 |
| All Kubernetes VMs | 13 | 78 | 192 |
| Kubernetes guests on hv01 | 7 | 22 | 104 |
| Kubernetes guests on hv02 | 6 | 56 | 88 |

These totals exclude hypervisor overhead, other infrastructure guests and the management entry with blank resource fields. They describe declared VM allocations rather than CPU usage, Kubernetes requests/limits or physical CPU cores. The V100 note associates the device with core-wk05 in the inventory; driver, exposure mode, licensing and CUDA/model results retain their own evidence records.

## Reconcile inventory and measured resources

The declared worker CPU total of **64 vCPU** agrees with the earlier worker dashboard's **64 CPU** capacity/allocatable reading. The inventory's **152 RAM values with no unit** and the dashboard's **124.9 GiB capacity / 124.1 GiB allocatable** remain distinct records. Do not replace the dashboard values with inventory totals or diagnose the difference without checking current VM configuration and Node data.

Only the selected core-cp01 screenshot supplies a per-node measurement: **2 CPU capacity/allocatable**, with **7.76 GiB memory capacity and 7.66 GiB allocatable**. Inventory values are now available for all thirteen VMs, but they do not supply exact Node API quantities for the other twelve. In particular, core-cp04 and core-cp05 are listed with **4 vCPU**, not the **2 vCPU** of core-cp01–03.

Review each host's private `qm list` and `qm config VMID`, recording the configured memory unit, any ballooning limits and current placement. Compare a fresh private Node export through [cluster-resources.py](../scripts/cluster-resources.py). Resolve the RAM unit and any configuration drift before resizing guests or making an admission/headroom claim. Do not total guest RAM values against physical host GiB until the units and memory behavior are established.

## Use the generic example

The [Den-sized example inventory](../automation/ansible/inventory.observed.example.yml) carries `reforge_hypervisor`, `reforge_inventory_vcpus`, `reforge_inventory_ram_value` and an optional `reforge_inventory_gpu` note. `reforge_inventory_ram_unit` is intentionally empty. These fields document the inventory; they do not resize VMs, configure GPU passthrough or make a host join Kubernetes.

Example addresses and interfaces remain placeholders rather than copies of operational endpoints. Keep the original alias/address mapping in ignored local files. The [acceptance guide](acceptance.md) and [experiment ledger](den-validations-experiments.md) remain the place for functional and failure/recovery results.
