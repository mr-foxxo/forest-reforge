# R710 + P4: recovered experimental host runbook

[English (default)](r710-p4-vgpu-runbook.md) | [Português (Brasil)](pt-BR/r710-p4-vgpu-runbook.md) | [Documentation index](README.md)

## Evidence and scope

The newly supplied July 22 chat records the owner's R710 revision II, dual 870 W PSUs, successful CPU replacement with X5690s, P4 installed in Riser 2's x16 slot, no other additional expansion card, and the deliberate requirement to explore Proxmox 9.2 with a 7.x kernel. This extends the earlier 9.1 trouble history; it does not prove a 9.1 installation used the same tuple.

The final proposed host procedure used **NVIDIA vGPU 16.14 / Linux KVM Manager 535.309.01**. NVIDIA's release table independently confirms that package mapping. The owner then reported the driver installed and later clarified `vgpud` finished successfully. No actual `uname -r`, complete post-install log, final patch diff or successful guest CUDA result appears in the export. Mark this **source-reported host milestone**, not a completely validated stack.

The later host summary reviewed on 2026-10-28 now displays kernel **7.0.14-5-pve** and Proxmox manager **9.2.4** for the corresponding generic hv01. This establishes a later displayed host tuple, but that image contains no NVIDIA driver/module/profile or guest workload result. Do not attach the chat's 535.309.01 milestone to that kernel without fresh driver evidence. See the [current platform observation](den-case-study.md).

The chat's initial V100 lane proposed 19.5 / 580.159.01 and a 7.0 kernel. That is a separate proposed tuple; no V100 installation result is shown. Do not combine Pascal and Volta recipes.

## Card identity and R710 constraints

The owner initially gave `10de:11d8`. The chat interpreted this as the **subsystem** ID, with primary P4 device ID `10de:1bb3`. Capture both fields rather than binding by the ambiguous first report. The second board label `699-2G414-101 C` is inventory evidence, not proof of a lower-power variant.

The chat also discusses the R710 expansion-slot power budget and the danger of assuming a 75 W GPU is officially supported because the system has large PSUs. Confirm the exact riser/chassis rating. A software power cap takes effect after driver initialization and is not a hardware guarantee for startup/transients. Keep R710/P4 use experimental where the electrical or thermal qualification is outside Dell's supported combination.

## Reconstruct the host installation

1. Preserve local/iDRAC recovery, host/VM config and a known-working bootable kernel. Freeze the exact current kernel during the experiment; do not combine installation with a full system upgrade.
2. Record `pveversion -v`, `uname -r`, firmware, bootloader, `lspci -Dnnk`, DKMS state and Secure Boot state. Identify the selected card's BDF explicitly.
3. Install matching headers/build prerequisites using package names available for the installed Proxmox release. The historical procedure used `proxmox-headers-$(uname -r)` and `pve-nvidia-vgpu-helper setup`; inspect helper effects first.
4. Enable/verify IOMMU and correct bootloader command line. Preserve unrelated kernel options and unrelated VFIO devices.
5. For mediated vGPU, remove **only this card's** VFIO binding. Inspect and remove conflicting driver installations using their own package/uninstaller mechanism. Do not wildcard-purge unrelated packages.
6. Obtain the entitled `NVIDIA-Linux-x86_64-535.309.01-vgpu-kvm.run`, record its checksum and retain a pristine private copy. The similarly numbered ordinary compute installer is not the vGPU Manager.
7. Extract a private source copy and preserve pristine versus modified state. Try the exact stock installer first with DKMS. The historical plan explicitly avoided speculative patches.
8. If it fails, preserve installer and DKMS build logs and identify the first compile error. Do not reboot into an incomplete replacement driver.
9. Apply only an error-matched patch with provenance, record the diff/checksum and rebuild. Confirm both `nvidia` and `nvidia_vgpu_vfio` exist for the intended kernel.
10. Reboot through the recovery path, then verify device binding, core driver, manager result and native profiles. Only then proceed to a stopped test VM.

## Patch investigation map

| Error family from the chat | File/API to inspect | Qualification requirement |
|---|---|---|
| VMA lock rename/signature | `nv-mmap.c`, VMA lock helpers | Compare exact kernel API and driver revision |
| DMA fence return type | `nvidia-dma-fence-helper.h` | Preserve semantics; avoid blind text replacement |
| DRM-only build problem | Installer's documented DRM options | Verify vGPU core/VFIO still built |
| VFIO IRQ bypass API | `nvidia-vgpu-vfio.c`, kernel IRQ bypass headers | Proprietary manager-specific; open-module tree is not a full replacement |

The chat cites NVIDIA's matching open-module source as a compatibility reference donor. It does **not** make open kernel modules runnable on Pascal. No final applied patch was supplied; no fabricated patch is included here.

## Service state: inspect results, not just the green dot

```bash
systemctl show nvidia-vgpud.service \
  -p Type -p ActiveState -p SubState -p Result -p ExecMainStatus
systemctl show nvidia-vgpu-mgr.service \
  -p Type -p ActiveState -p SubState -p Result -p ExecMainStatus
nvidia-smi
modinfo nvidia_vgpu_vfio
mdevctl types
```

In the reported case, `vgpud` could finish with exit 0 while the manager remained the ongoing service. An inactive service alone is insufficient to diagnose failure: inspect the installed unit, its result, manager logs and profile visibility. This corrects earlier advice that treated every non-active `vgpud` as broken.

Kernel taint messages about proprietary/out-of-tree code are not themselves failed GPU initialization. Investigate actual module-load errors, device initialization failures, Xid/PCIe faults and missing profiles.

## First guest: source proposal, not confirmed outcome

| Setting | Proposed initial test |
|---|---|
| Machine / firmware | q35 / OVMF, retain standard virtual VGA |
| CPU / RAM | host CPU, one socket, 4 cores, 16 GiB, ballooning off |
| Disk / network | ≥64 GB, VirtIO SCSI, VirtIO NIC, guest agent |
| vGPU | P4-4Q if exposed/available and suitable for licensed workload |
| Guest driver | Matching GRID guest package, not host KVM Manager |
| Lifecycle | No autostart, migration or hotplug during qualification |

Discover the numerical `nvidia-*` mdev ID locally; do not copy one from a forum. Attach while the VM is stopped. Keep remote access and virtual VGA until guest GPU behavior is proven. Configure legitimate guest licensing; do not overwrite the GRID guest driver by installing a CUDA bundle's unrelated driver.

Test guest driver → license state → small CUDA operation → application → repeated VM restart → host reboot. Record temperature and PCIe error behavior. Query firmware power limits for the selected BDF before considering a supported cap; do not hard-code an unobserved wattage or apply it to every card.

## References

- [Sanitized vGPU chat](../reference/chat-history/vgpu-proxmox.md)
- [NVIDIA vGPU 16 KVM release table](https://docs.nvidia.com/vgpu/16.0/grid-vgpu-release-notes-generic-linux-kvm/index.html)
- [Proxmox vGPU guide](https://pve.proxmox.com/wiki/NVIDIA_vGPU_on_Proxmox_VE_7.x)

The Proxmox page returned an access error during this research session; the chat's exact Proxmox test-table claims are retained as historical claims rather than independently revalidated here.
