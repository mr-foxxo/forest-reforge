#!/usr/bin/env bash
# Read-only: does not dump Secrets, kubeconfig credentials or application logs.
set -uo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: cluster-troubleshoot.sh CONTEXT\nCollects Cilium/L2, Gateway, certificate, storage and GitOps conditions. Keep output private.\n'
  exit 0
fi
[[ $# == 1 && -n $1 ]] || exit 2
context=$1 failed=0
command -v kubectl >/dev/null || exit 2
run() {
  printf '\n## %s\n' "$1"; shift
  kubectl --context "$context" --request-timeout=20s "$@" || { printf 'CHECK FAILED: check RBAC, CRDs or API health.\n' >&2; failed=1; }
}
run 'API readiness' get --raw=/readyz
run 'Nodes' get nodes -o wide
run 'Cilium agents' -n kube-system get daemonsets cilium
run 'L2 pools and policies' get ciliumloadbalancerippools,ciliuml2announcementpolicies
run 'L2 leases' -n kube-system get leases
run 'Gateway/route conditions' get gateways,httproutes -A -o wide
run 'Services and backends' get services,endpointslices -A
run 'ACME conditions' get certificates,certificaterequests,orders.acme.cert-manager.io,challenges.acme.cert-manager.io -A
run 'Persistent storage' get storageclasses,persistentvolumes,persistentvolumeclaims -A
run 'GitOps health' get applications.argoproj.io -A
run 'Pod scheduling' get pods -A -o wide
printf '\nCompare each failing layer with docs/troubleshooting.md. No repair was attempted.\n'
exit "$failed"

