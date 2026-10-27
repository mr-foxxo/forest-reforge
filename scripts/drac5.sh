#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ${1:-} == --help ]]; then
  printf 'Usage: drac5.sh build|start|vnc|status|down\nUses automation/drac5; prepare private assets using docs/automation.md first.\n'
  exit 0
fi
[[ $# == 1 ]] || exit 2
cd "$root/automation/drac5"
case "$1" in
  build) docker compose build ;;
  start) docker compose up -d --no-build ;;
  vnc)
    docker compose up -d --no-build
    printf 'Open vnc://127.0.0.1:5900; enable Pass all keystrokes to target in Session Options.\n'
    ;;
  status) docker compose ps ;;
  down) docker compose down ;;
  *) exit 2 ;;
esac
