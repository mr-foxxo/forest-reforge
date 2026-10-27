#!/usr/bin/env bash
# Reads one generic Secret's data keys from a protected local directory.
set -Eeuo pipefail
umask 077
if [[ ${1:-} == --help ]]; then
  printf 'Usage: secret-file.sh plan|apply CONTEXT NAMESPACE SECRET_NAME PRIVATE_DIRECTORY [argocd-repository]\nEach regular file becomes one data key. Values never appear in command arguments or output.\n'
  exit 0
fi
[[ $# -ge 5 && $# -le 6 ]] || exit 2
action=$1 context=$2 namespace=$3 name=$4 directory=$5 label=${6:-}
[[ $action == plan || $action == apply ]] || exit 2
[[ $namespace =~ ^[a-z0-9-]+$ && $name =~ ^[a-z0-9-]+$ && -d $directory && ( -z $label || $label == argocd-repository ) ]] || exit 2
printf 'Create/update %s/%s in explicit context %s from private files.\n' "$namespace" "$name" "$context"
[[ $action == apply ]] || exit 0
command -v kubectl >/dev/null
command -v jq >/dev/null
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
args=()
for file in "$directory"/*; do
  [[ -f $file && ! -L $file ]] || continue
  key=${file##*/}
  [[ $key =~ ^[a-zA-Z0-9_.-]+$ ]] || { printf 'Invalid Secret data filename.\n' >&2; exit 2; }
  args+=(--from-file="$key=$file")
done
(( ${#args[@]} > 0 )) || { printf 'No regular data files.\n' >&2; exit 2; }
kubectl --context "$context" -n "$namespace" create secret generic "$name" "${args[@]}" --dry-run=client -o json > "$workspace/secret.json"
if [[ $label == argocd-repository ]]; then
  jq '.metadata.labels["argocd.argoproj.io/secret-type"]="repository"' "$workspace/secret.json" > "$workspace/labeled.json"
  mv "$workspace/labeled.json" "$workspace/secret.json"
fi
kubectl --context "$context" apply --server-side --field-manager=reforge-secret-bootstrap -f "$workspace/secret.json"

