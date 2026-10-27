#!/usr/bin/env bash
# Read-only, BDF-scoped evidence. Logs may contain private identifiers.
set -uo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: gpu-diagnose.sh PCI_BDF [KERNEL]\nExample: gpu-diagnose.sh 0000:05:00.0\nCollect privately; review before sharing. No driver or boot changes.\n'
  exit 0
fi
[[ $# -ge 1 && $# -le 2 && $1 =~ ^[[:xdigit:]]{4}:[[:xdigit:]]{2}:[[:xdigit:]]{2}\.[0-7]$ ]] || { printf 'Supply one full PCI BDF.\n' >&2; exit 2; }
bdf=$1 kernel=${2:-$(uname -r)} failed=0
[[ -d /sys/bus/pci/devices/$bdf ]] || { printf 'Selected PCI device does not exist.\n' >&2; exit 2; }
run() {
  printf '\n## %s\n' "$1"; shift
  if ! command -v "$1" >/dev/null 2>&1; then printf 'SKIP: %s unavailable\n' "$1"; return; fi
  "$@" || { printf 'CHECK FAILED: %s\n' "$1" >&2; failed=1; }
}
run 'Kernel' uname -r
run 'Selected PCI device' lspci -Dnnk -s "$bdf"
run 'CPU instruction flags' lscpu
run 'Installed kernels' pveversion -v
run 'Boot configuration status' proxmox-boot-tool status
run 'Secure Boot' mokutil --sb-state
run 'DKMS builds' dkms status
for module in nvidia nvidia_vgpu_vfio vfio_pci; do
  run "Module for $kernel: $module" modinfo -k "$kernel" "$module"
done
run 'Selected GPU' nvidia-smi -i "$bdf" --query-gpu=name,pci.bus_id,driver_version,memory.total,temperature.gpu,power.draw --format=csv
for unit in nvidia-vgpud.service nvidia-vgpu-mgr.service; do
  run "$unit result" systemctl show "$unit" -p Type -p ActiveState -p SubState -p Result -p ExecMainStatus
  run "$unit recent logs" journalctl -b -u "$unit" --no-pager -n 80
done
printf '\n## IOMMU peers\n'
if [[ -d /sys/bus/pci/devices/$bdf/iommu_group/devices ]]; then
  for peer in /sys/bus/pci/devices/"$bdf"/iommu_group/devices/*; do printf '%s\n' "${peer##*/}"; done
else
  printf 'No IOMMU group for selected device.\n'; failed=1
fi
printf '\n## Native mediated profiles\n'
for profile in /sys/bus/pci/devices/"$bdf"/mdev_supported_types/*; do
  [[ -d $profile ]] || continue
  printf '%s ' "${profile##*/}"
  for field in name available_instances; do [[ ! -r $profile/$field ]] || tr '\n' ' ' < "$profile/$field"; done
  printf '\n'
done
printf '\nAn inactive vgpud with Result=success and ExecMainStatus=0 alone is not a failure.\nInspect manager, binding and profiles together. Missing optional modules can be expected for passthrough.\n'
exit "$failed"

