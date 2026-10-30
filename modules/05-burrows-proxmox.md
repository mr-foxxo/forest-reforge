# 05 · Burrows — hypervisors and guest foundations

[English (default)](05-burrows-proxmox.md) | [Português (Brasil)](../docs/pt-BR/modules/05-burrows-proxmox.md) | [Documentation index](../docs/README.md)

Automation: `burrows` prepares the selected bootloader's IOMMU settings; [proxmox-vm.sh](../scripts/proxmox-vm.sh) imports a checked image into a new stopped guest. Read the [private contract and recovery requirements](../docs/automation.md) first.

## Install and separate concerns

1. Confirm OOB/local console and a bootable rescue path before installation.
2. Select a Proxmox release and kernel from the GPU qualification requirements, not just the newest ISO.
3. Install to identified boot media; review disk targets before any destructive installer step.
4. Configure time sync, DNS, hostname and repositories appropriate to the installed release/subscription. Record package versions.
5. Create management and workload bridges that correspond to physical network attachments. Do not bridge the OOB or unrelated security zones together.
6. Create a non-root administrative identity with appropriate roles and retain secured local break-glass access.
7. Set up an independent backup destination and restore a small guest before deploying the cluster.

The reference host uses separate physical segments rather than VLAN trunking. A VM placed on the Servers bridge participates in that L2 domain; a VM on the VM bridge does not automatically reach a Servers VIP through ARP.

## VM template contract

Use a pinned OS image/checksum; cloud-init where supported; VirtIO network and disk; qemu guest agent; fixed resource limits; stable MAC/IP reservations; known DNS/NTP; and SSH keys rather than shared passwords. Clone before installing kubeadm so machine identity and node names are unique.

The [current inventory](../docs/den-inventory.md) declares 2 vCPU for core-cp01–03, 4 for core-cp04–05, and heterogeneous worker allocations totaling 64 vCPU. Declared Kubernetes guests total 22 vCPU on hv01 and 56 on hv02. The RAM column has no unit: its host-group totals of 104 and 88 are not directly comparable to the earlier physical-host panels' 125.87/62.65 GiB. Resolve memory units/current VM settings before sizing. The selected core-cp01 panel measures 7.66 GiB allocatable, and the earlier worker dashboard aggregates 124.1 GiB; these measured records remain separate from inventory declarations. Reserve RAM for hosts, caches and other guests; KSM is not an extra physical RAM pool.

CPU `host` can expose useful instructions but restrict migration across different CPU generations. With passthrough GPUs, treat guests as tied to the physical device unless migration support has explicitly been proven. Record NUMA topology for dual-socket hosts and check memory/PCI locality under load.

For a new GPU guest, Q35/UEFI is a common candidate; verify guest and card behavior rather than rewriting an existing working VM. Keep a virtual console for headless Tesla cards. Choose dedicated RAM when latency and capacity predictability matter.

## Kernel/driver upgrade gate

Record `pveversion -v`, `uname -r`, boot mode, package selection, kernel headers, DKMS status, GPU driver and guest versions. Preserve the previous bootable kernel until a full reboot/workload test passes. Test selection via the actual bootloader (`proxmox-boot-tool status` where applicable); do not blindly assume GRUB.

Proxmox's 9.1 release notes call out GRID compatibility with kernel 6.17 and branch 19.4. This does **not** make P4 supported by branch 19.4. Newer desired 7.x kernels remain unqualified for the historical P4 experiment here.

Back up host configuration and VM configuration; preserve licensed installer checksums and patch provenance privately. Upgrade one GPU host first. If module build/load or a guest workload fails, boot the known-good kernel and restore the matched driver configuration before trying unrelated changes.

## Storage boundaries

Do not layer ZFS on a hardware RAID virtual disk without a deliberate supported design; know which layer owns redundancy and error reporting. The NAS screenshot shows TrueNAS and two ONLINE single-disk pools. It does not establish a Proxmox ZFS datastore, PBS, Ceph, Kubernetes exports or tested recovery. Keep those deployment claims separate.

A VM snapshot on the same failed datastore is not an off-host backup. Test application-consistent backups for stateful services and keep the encryption material needed to restore them.

Upstream: [Proxmox roadmap/release notes](https://pve.proxmox.com/wiki/Roadmap), [PCI passthrough](https://pve.proxmox.com/wiki/PCI(e)_Passthrough).
