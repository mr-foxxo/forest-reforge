#!/usr/bin/env bash
# Run from any directory. Inventory, site and vault are always explicit.
set -Eeuo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
usage() {
  cat <<'USAGE'
Usage: reforge.sh plan|apply PHASE INVENTORY SITE [VAULT]
Phases: roots canopy paths names vault gatehouse trails lookout baseline
        backstage edge backup burrows embers
plan uses Ansible --check; it is a partial preview, not an offline renderer.
apply changes only the selected phase. No deployment runs on --help.
USAGE
}
[[ ${1:-} != --help && $# -ge 4 && $# -le 5 ]] || { usage; [[ ${1:-} == --help ]]; exit; }
action=$1 phase=$2 inventory=$3 site=$4
case "$action" in plan|apply) ;; *) usage >&2; exit 2 ;; esac
case "$phase" in
  roots) playbook=01-roots ;; canopy) playbook=02-canopy ;; paths) playbook=03-paths ;;
  names) playbook=04-names ;; vault) playbook=05-vault ;; gatehouse) playbook=06-gatehouse ;;
  trails) playbook=07-trails ;; lookout) playbook=08-lookout ;; baseline) playbook=09-baseline ;;
  backstage) playbook=10-backstage ;; edge) playbook=11-edge ;; backup) playbook=12-backup ;;
  burrows) playbook=13-burrows ;; embers) playbook=14-embers ;;
  *) printf 'Unknown phase: %s\n' "$phase" >&2; exit 2 ;;
esac
absolute_file() {
  [[ -f $1 ]] || { printf 'Missing file: %s\n' "$1" >&2; exit 2; }
  printf '%s/%s\n' "$(cd -- "$(dirname -- "$1")" && pwd)" "$(basename -- "$1")"
}
inventory=$(absolute_file "$inventory")
site=$(absolute_file "$site")
args=(-i "$inventory" -e "@$site")
if [[ $# == 5 ]]; then
  vault=$(absolute_file "$5")
  args+=(-e "@$vault" --ask-vault-pass)
fi
[[ $action != plan ]] || args+=(--check)
command -v ansible-playbook >/dev/null || { printf 'Install the controller dependencies documented in docs/automation.md\n' >&2; exit 2; }
cd "$root/automation/ansible"
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
exec ansible-playbook "${args[@]}" "playbooks/$playbook.yml"

