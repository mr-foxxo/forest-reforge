# 06 · Embers — make legacy acceleration useful

Helpers: `embers` installs selected prerequisites; [gpu-diagnose.sh](../scripts/gpu-diagnose.sh), [kernel-gate.sh](../scripts/kernel-gate.sh), [gpu-driver.sh](../scripts/gpu-driver.sh) and [vgpu-attach.sh](../scripts/vgpu-attach.sh) support qualification. See the [automation guide](../docs/automation.md).

Read [the compatibility matrix](../docs/compatibility.md) first. Choose a single card and a single workload before constructing a shared GPU platform.

The [Den experiment ledger](../docs/den-validations-experiments.md#experiment-ledger) now records node-feature-discovery master/worker metrics in a selected control-plane view. This is concrete discovery-component evidence. Continue with GPU-node PCI/label/device-resource inspection and a CUDA workload before recording driver, device-plugin, vGPU or model success.

## Choose an exposure model

| Model | Ownership | Benefit | Cost/limit |
|---|---|---|---|
| Bare metal | Host driver owns GPU | Simple compute experiment | Adds application dependencies to host |
| PCIe passthrough | VFIO host, guest compute driver | Isolated full-device compute | One guest owns device; reset/migration limits |
| Licensed vGPU | Host vGPU Manager + supported guest driver | Supported virtual profiles where available | Matrix, entitlement, kernel and guest coupling |
| Patched/unsupported vGPU | Locally modified stack | Research | No vendor support claim; reproducibility burden |

For these reused hosts, full passthrough to a compute VM is the default qualification route. Add vGPU only where its sharing value justifies complexity. None of these cards supplies modern MIG partitioning.

## Full passthrough procedure

1. Confirm cooling, power and hardware identity. Capture a baseline with `scripts/host-audit.sh` privately.
2. Enable the CPU/platform virtualization and IOMMU facilities in firmware. Check kernel logs and `/sys/kernel/iommu_groups` after reboot.
3. Inspect every member of the GPU's IOMMU group. A group shared with essential host devices cannot safely be assigned wholesale. Do not use ACS override as proof of isolation.
4. Determine the complete device/function set for the card and preserve the host display/recovery device. Configure VFIO binding for the intended GPU using the installed Proxmox documentation and verified identifiers.
5. Verify `lspci -nnk` shows the intended binding before attaching the device to a powered-off test VM. The host NVIDIA driver and VFIO cannot both own that same physical device.
6. Start the guest with a virtual console retained. Install a compatible proprietary compute driver inside the guest, then reboot.
7. Run `nvidia-smi`, a real CUDA operation and the intended application. Observe clocks, thermal/power limits and memory behavior.
8. Shut down/start the VM repeatedly and reboot the host once. A first successful boot does not prove device-reset reliability.
9. Record the stack and backup/restore behavior before placing persistent work on it.

## vGPU qualification procedure

1. Check the exact GPU's supported branch and the vendor/hypervisor/guest matrix. For P4 the official ceiling is branch 16; for V100 it is branch 19. M40 has no official vGPU path.
2. Obtain host and guest packages through legitimate entitlement/evaluation channels. Keep binary distribution outside the public repo.
3. Match kernel headers and compiler requirements; inspect Secure Boot/module-signing requirements for the host. Check the NVIDIA installer or DKMS build log for the **first real error**.
4. Install the vGPU Manager according to the supported platform guide. Do not mix it with a generic host compute driver for the same device.
5. Confirm the module loaded and the manager services are healthy; inspect supported mediated-device/profile interfaces documented for the chosen release. Do not assume a modern SR-IOV recipe applies to an older mediated-device GPU.
6. Choose a profile that supports the intended compute use and framebuffer requirement. Record its identifier rather than hard-coding an unobserved profile name.
7. Attach the profile using the installed Proxmox device mapping mechanism. Install a guest driver from a permitted host/guest compatibility pairing.
8. Configure the documented guest licensing client with a legitimate license-service configuration token/credentials. Validate guest license state and actual CUDA execution.
9. Reboot host and guest, test profile persistence and repeat application acceptance.

A host vGPU Manager and guest license client are different components. The historical conversation confused `nvidia-vgpud` with guest `nvidia-gridd`; host taint messages do not establish a guest licensing problem.

## The Proxmox 9.1 lesson

The added export identifies the final proposed P4 host installer as vGPU **16.14 / 535.309.01**, targeting Proxmox 9.2 and an exact-to-be-recorded 7.x kernel. The owner reported installation and `vgpud` success. P4-4Q was then proposed for the first guest. Exact running kernel, applied patch (if any), reboot logs and successful guest inference remain unrecorded. See [the recovered host runbook](../docs/r710-p4-vgpu-runbook.md); it does not establish a working 9.1/9.2 + GRID 19.4 P4 tuple.

The vendor P4 branch ceiling conflicts with that earlier 19.4 ambition. Proxmox 9.1's kernel compatibility advice for branch 19.4 does not extend that branch to unsupported GPUs. Keep two lanes: a conservative supported stack where one exists, and a separately labeled patched experiment with exact diffs/checksums and a rollback kernel.

The history mentions fastapi-dls. Its presence is not proof of NVIDIA entitlement, official support or successful guest licensing. This public guide uses the documented licensed path and does not ship license bypasses.

## Troubleshooting order

```bash
uname -r
pveversion -v
dkms status
lspci -nnk
journalctl -k -b --no-pager
systemctl status nvidia-vgpud --no-pager
journalctl -u nvidia-vgpud -b --no-pager
nvidia-smi
```

Run the applicable commands on the host; absence of vGPU services is expected in a pure passthrough setup. On the guest, inspect the guest driver/license client instead. The export clarifies that `vgpud` may exit successfully while `nvidia-vgpu-mgr` remains running. Inspect unit type, result/exit status and profiles rather than requiring every service to remain active. Out-of-tree/proprietary-module taint is expected metadata; unresolved symbols, API mismatches, signature rejection, missing devices and Xid errors need investigation.

Rollback: stop affected guests, boot the preserved kernel, restore the matched driver/device configuration and rerun the same workload. Do not upgrade the application framework at the same time as the kernel when isolating regressions.
