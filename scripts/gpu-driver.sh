#!/usr/bin/env bash
# Verify and extract an operator-provided proprietary installer; no driver install.
set -Eeuo pipefail
umask 077
if [[ ${1:-} == --help ]]; then
  printf 'Usage: gpu-driver.sh INSTALLER SHA256 NEW_PRIVATE_DIRECTORY\nVerifies the checksum then extracts for inspection. Does not install, patch or reboot.\n'
  exit 0
fi
[[ $# == 3 && $2 =~ ^[a-fA-F0-9]{64}$ && -f $1 && ! -e $3 ]] || { printf 'Supply installer, checksum and a new private extraction path.\n' >&2; exit 2; }
installer=$(cd -- "$(dirname -- "$1")" && pwd)/$(basename -- "$1")
if command -v sha256sum >/dev/null; then actual=$(sha256sum "$installer"); else actual=$(shasum -a 256 "$installer"); fi
[[ ${actual%% *} == "$2" ]] || { printf 'Installer checksum mismatch.\n' >&2; exit 1; }
mkdir -m 700 -- "$3"
destination=$(cd -- "$3" && pwd)
bash "$installer" --extract-only --target "$destination"
printf 'Extracted privately. Compare stock build errors with the runbook before patching.\nRecord driver flavor, kernel, headers, checksum and any final patch diff.\n'

