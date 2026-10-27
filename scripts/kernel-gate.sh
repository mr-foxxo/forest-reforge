#!/usr/bin/env bash
# Verifies installed artifacts; it never pins kernels, rebuilds or reboots.
set -Eeuo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: kernel-gate.sh TARGET_KERNEL passthrough|vgpu|compute\nChecks files/modules for a proposed kernel. A pass does not prove runtime compatibility.\n'
  exit 0
fi
[[ $# == 2 && $1 =~ ^[a-zA-Z0-9.+_-]+$ ]] || exit 2
kernel=$1
case "$2" in passthrough) modules=(vfio_pci) ;; compute) modules=(nvidia) ;; vgpu) modules=(nvidia nvidia_vgpu_vfio) ;; *) exit 2 ;; esac
failed=0
for file in "/boot/vmlinuz-$kernel" "/boot/initrd.img-$kernel" "/lib/modules/$kernel/build/Makefile"; do
  [[ -s $file ]] || { printf 'Missing or empty: %s\n' "$file" >&2; failed=1; }
done
command -v modinfo >/dev/null || { printf 'modinfo required\n' >&2; exit 2; }
for module in "${modules[@]}"; do
  vermagic=$(modinfo -k "$kernel" -F vermagic "$module") || { failed=1; continue; }
  [[ ${vermagic%% *} == "$kernel" ]] || { printf 'Kernel mismatch for %s: %s\n' "$module" "$vermagic" >&2; failed=1; }
done
if (( failed )); then printf 'Gate failed. Keep the known-working boot selection.\n' >&2; exit 1; fi
printf 'Artifacts present for %s. Verify DKMS, signatures, initramfs contents and recovery console before selecting this kernel.\n' "$kernel"

