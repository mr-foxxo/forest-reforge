#!/usr/bin/env bash
# Local read-only evidence collector. Review/redact output before sharing.
set -uo pipefail
failed=0
run() {
  printf '\n## %s\n' "$1"
  shift
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'SKIP: tool unavailable: %s\n' "$1"
    return
  fi
  "$@"
  local rc=$?
  if (( rc != 0 )); then
    printf 'CHECK FAILED: exit %s\n' "$rc" >&2
    failed=1
  fi
}
run 'Kernel' uname -r
run 'CPU capabilities' lscpu
run 'PCI devices and drivers' lspci -nnk
run 'Block layout (no serial numbers requested)' lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS
run 'Proxmox versions, if installed' pveversion -v
run 'DKMS, if installed' dkms status
run 'GPU identity, if driver available' nvidia-smi --query-gpu=name,pci.bus_id,driver_version,memory.total --format=csv
printf '\n## IOMMU groups\n'
if [[ -d /sys/kernel/iommu_groups ]]; then
  for group in /sys/kernel/iommu_groups/*; do
    [[ -d "$group/devices" ]] || continue
    printf 'Group %s:' "${group##*/}"
    for device in "$group"/devices/*; do
      [[ -e "$device" ]] && printf ' %s' "${device##*/}"
    done
    printf '\n'
  done
else
  printf 'No IOMMU group directory; investigate platform/kernel configuration.\n'
fi
printf '\nCollector only: no acceptance verdict. Keep output private until redacted.\n'
exit "$failed"
