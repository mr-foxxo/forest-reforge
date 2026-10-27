#!/usr/bin/env bash
# Uses current kubectl context. Does not fetch Secret contents or mutate resources.
set -uo pipefail
command -v kubectl >/dev/null 2>&1 || { printf 'kubectl is required\n' >&2; exit 2; }
failed=0
run() {
  printf '\n## %s\n' "$1"
  shift
  kubectl --request-timeout=15s "$@"
  local rc=$?
  if (( rc != 0 )); then
    printf 'CHECK FAILED: exit %s (check context, RBAC, API/CRD availability)\n' "$rc" >&2
    failed=1
  fi
}
run 'Current context' config current-context
run 'API readiness' get --raw=/readyz
run 'Nodes' get nodes -o wide
run 'System DaemonSets' -n kube-system get daemonsets
run 'Gateway and route conditions summary' get gateway,httproute -A
run 'Services' get services -A -o wide
run 'Certificates' get certificates -A
run 'StorageClasses' get storageclasses
run 'Argo Applications' get applications.argoproj.io -A
printf '\nRead-only collection finished; no deployment acceptance claim.\n'
exit "$failed"
