#!/usr/bin/env bash
# Imports an operator-reviewed cloud image into a new, stopped guest.
set -Eeuo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: proxmox-vm.sh plan|apply VMID NAME STORAGE BRIDGE IMAGE SHA256 SSH_PUBLIC_KEY\nRequired environment: REFORGE_VM_IPCONFIG (ip=.../prefix,gw=...), REFORGE_VM_DNS\nOptional: REFORGE_VM_CORES=4 REFORGE_VM_MEMORY=8192 REFORGE_VM_USER=platform\nCreates only a new VM. No image downloads, disk wipes, VM starts or overwrites.\n'
  exit 0
fi
[[ $# == 8 ]] || exit 2
action=$1 vmid=$2 name=$3 storage=$4 bridge=$5 image=$6 checksum=$7 key=$8
[[ $action == plan || $action == apply ]] || exit 2
[[ $vmid =~ ^[1-9][0-9]+$ && $name =~ ^[a-z][a-z0-9-]+$ && $storage =~ ^[a-zA-Z0-9_-]+$ && $bridge =~ ^[a-zA-Z0-9_.-]+$ ]] || exit 2
[[ $checksum =~ ^[a-f0-9]{64}$ && -s $image && -s $key ]] || exit 2
: "${REFORGE_VM_IPCONFIG:?Set an explicit static guest address and gateway}"
: "${REFORGE_VM_DNS:?Set an independent DNS server}"
cores=${REFORGE_VM_CORES:-4} memory=${REFORGE_VM_MEMORY:-8192} user=${REFORGE_VM_USER:-platform}
[[ $cores =~ ^[1-9][0-9]*$ && $memory =~ ^[1-9][0-9]*$ && $user =~ ^[a-z][a-z0-9_-]*$ ]] || exit 2
actual=$(sha256sum "$image")
[[ ${actual%% *} == "$checksum" ]] || { printf 'Cloud image checksum mismatch.\n' >&2; exit 1; }
image=$(cd -- "$(dirname -- "$image")" && pwd)/$(basename -- "$image")
key=$(cd -- "$(dirname -- "$key")" && pwd)/$(basename -- "$key")
[[ ! -e /etc/pve/qemu-server/$vmid.conf ]] || { printf 'VMID already exists; no changes made.\n' >&2; exit 1; }
command=(qm create "$vmid" --name "$name" --memory "$memory" --cores "$cores" \
  --cpu host --net0 "virtio,bridge=$bridge" --scsihw virtio-scsi-single \
  --scsi0 "$storage:0,import-from=$image" --ide2 "$storage:cloudinit" \
  --boot 'order=scsi0' --serial0 socket --vga serial0 --agent enabled=1 \
  --ciuser "$user" --sshkeys "$key" --ipconfig0 "$REFORGE_VM_IPCONFIG" \
  --nameserver "$REFORGE_VM_DNS" --onboot 0)
printf '%q ' "${command[@]}"; printf '\n'
[[ $action == apply ]] || exit 0
"${command[@]}"
printf 'VM created and left stopped. Inspect qm config %s before starting.\nA failed import may leave a partial VM; inspect its attached volumes before cleanup.\n' "$vmid"
