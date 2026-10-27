#!/usr/bin/env bash
# Run locally on a stacked-etcd control plane; backup contains private keys.
set -Eeuo pipefail
umask 077
if [[ ${1:-} == --help ]]; then
  printf 'Usage: sudo REFORGE_BACKUP_ROOT=/var/backups/reforge etcd-backup.sh --apply\nOptional: REFORGE_BACKUP_REMOTE=user@backup:/private/path (SSH known_hosts required).\n'
  exit 0
fi
[[ $# == 1 && $1 == --apply ]] || { printf 'Explicit --apply required to create a private backup.\n' >&2; exit 2; }
[[ $EUID == 0 ]] || { printf 'Run as root on a control plane.\n' >&2; exit 2; }
backup_root=${REFORGE_BACKUP_ROOT:-/var/backups/reforge}
[[ $backup_root =~ ^/var/backups/reforge(/[a-zA-Z0-9_-]+)*$ ]] || { printf 'Use a dedicated /var/backups/reforge path.\n' >&2; exit 2; }
for tool in etcdctl etcdutl sha256sum tar flock; do command -v "$tool" >/dev/null; done
exec 9>/run/lock/reforge-etcd-backup.lock
flock -n 9 || { printf 'Backup already running.\n' >&2; exit 1; }
for path in pki/etcd/ca.crt pki/etcd/healthcheck-client.crt pki/etcd/healthcheck-client.key reforge/encryption.yaml admin.conf; do
  [[ -r /etc/kubernetes/$path ]] || { printf 'Missing recovery prerequisite: %s\n' "$path" >&2; exit 1; }
done
mkdir -p "$backup_root"
chmod 700 "$backup_root"
destination=$(mktemp -d "$backup_root/snapshot-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")
# A partial bundle is kept for diagnosis but never marked COMPLETE.
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
  --key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
  snapshot save "$destination/etcd.db"
etcdutl snapshot status "$destination/etcd.db" -w json > "$destination/snapshot-status.json"
tar -C /etc -czf "$destination/kubernetes.tar.gz" kubernetes
(
  cd "$destination"
  sha256sum etcd.db kubernetes.tar.gz snapshot-status.json > SHA256SUMS
  sha256sum -c SHA256SUMS
)
if [[ -n ${REFORGE_BACKUP_REMOTE:-} ]]; then
  [[ $REFORGE_BACKUP_REMOTE == *@*:* && $REFORGE_BACKUP_REMOTE != -* ]] || { printf 'Remote must use user@host:/private/path.\n' >&2; exit 2; }
  rsync -a --checksum -e 'ssh -o BatchMode=yes -o StrictHostKeyChecking=yes' \
    -- "$destination/" "${REFORGE_BACKUP_REMOTE%/}/$(hostname -s)/${destination##*/}/"
fi
touch "$destination/COMPLETE"
printf 'Private recovery bundle: %s\nNo retention deletion performed. Verify an off-host restore separately.\n' "$destination"

