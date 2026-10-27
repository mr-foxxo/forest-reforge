#!/usr/bin/env bash
# Invoke from a private systemd timer/runner with renewable AWS credentials.
set -Eeuo pipefail
umask 077
if [[ ${1:-} == --help ]]; then
  printf 'Usage: ecr-refresh.sh plan|apply CONTEXT AWS_PROFILE REGION REGISTRY NAMESPACE [SECRET_NAME]\nExample registry: 123456789012.dkr.ecr.us-east-1.amazonaws.com\nRefresh before the 12-hour token expires; this does not configure its own scheduler.\n'
  exit 0
fi
[[ $# -ge 6 && $# -le 7 ]] || exit 2
action=$1 context=$2 profile=$3 region=$4 registry=$5 namespace=$6 secret=${7:-ecr-pull}
[[ $action == plan || $action == apply ]] || exit 2
[[ $region =~ ^[a-z0-9-]+$ && $registry =~ ^[0-9]{12}\.dkr\.ecr\.[a-z0-9-]+\.amazonaws\.com$ && $namespace =~ ^[a-z0-9-]+$ && $secret =~ ^[a-z0-9-]+$ ]] || exit 2
[[ $registry == *.dkr.ecr."$region".amazonaws.com ]] || { printf 'Registry and region differ.\n' >&2; exit 2; }
printf 'Refresh %s/%s in explicit context %s.\n' "$namespace" "$secret" "$context"
[[ $action == apply ]] || exit 0
for tool in aws kubectl jq; do command -v "$tool" >/dev/null; done
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
aws --profile "$profile" --region "$region" ecr get-login-password > "$workspace/password"
jq -n --arg registry "$registry" --rawfile password "$workspace/password" \
  '{auths:{($registry):{auth:(("AWS:" + ($password|rtrimstr("\n")))|@base64)}}}' > "$workspace/config.json"
kubectl --context "$context" -n "$namespace" create secret generic "$secret" \
  --type=kubernetes.io/dockerconfigjson --from-file=.dockerconfigjson="$workspace/config.json" \
  --dry-run=client -o json > "$workspace/secret.json"
kubectl --context "$context" apply --server-side --field-manager=reforge-ecr-refresh -f "$workspace/secret.json"

