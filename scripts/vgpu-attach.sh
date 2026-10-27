#!/usr/bin/env bash
set -Eeuo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: vgpu-attach.sh plan|apply VMID PCI_BDF MDEV_TYPE\nDiscovers the selected native profile; VM must be stopped and hostpci0 unused.\n'
  exit 0
fi
[[ $# == 4 && $2 =~ ^[1-9][0-9]+$ && $3 =~ ^[[:xdigit:]]{4}:[[:xdigit:]]{2}:[[:xdigit:]]{2}\.[0-7]$ && $4 =~ ^nvidia-[0-9]+$ ]] || exit 2
action=$1 vmid=$2 bdf=$3 profile=$4
[[ $action == plan || $action == apply ]] || exit 2
path=/sys/bus/pci/devices/$bdf/mdev_supported_types/$profile
[[ -r $path/name && -r $path/available_instances ]] || { printf 'Native profile not present on selected BDF.\n' >&2; exit 1; }
[[ $(cat "$path/available_instances") -gt 0 ]] || { printf 'No profile capacity available.\n' >&2; exit 1; }
[[ $(qm status "$vmid") == 'status: stopped' ]] || { printf 'Stop the test VM first.\n' >&2; exit 1; }
config=$(qm config "$vmid")
[[ $config != *'hostpci0:'* ]] || { printf 'hostpci0 already configured; no overwrite performed.\n' >&2; exit 1; }
printf 'Selected profile: %s\n' "$(cat "$path/name")"
printf 'qm set %q --hostpci0 %q\n' "$vmid" "$bdf,mdev=$profile,pcie=1"
[[ $action == apply ]] || exit 0
qm set "$vmid" --hostpci0 "$bdf,mdev=$profile,pcie=1"
printf 'Attached while stopped. Keep virtual VGA; validate guest licensing, CUDA, restarts and host errors.\nRollback while stopped: qm set %s --delete hostpci0\n' "$vmid"
