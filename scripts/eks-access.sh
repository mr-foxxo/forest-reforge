#!/usr/bin/env bash
# Use target-account operator credentials; grants namespace-scoped workload edit.
set -Eeuo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: eks-access.sh plan|apply AWS_PROFILE REGION CLUSTER PRINCIPAL_ROLE_ARN NAMESPACE\nRequires EKS API or API_AND_CONFIG_MAP authentication mode. Does not change cluster auth mode or IAM trust.\n'
  exit 0
fi
[[ $# == 6 ]] || exit 2
action=$1 profile=$2 region=$3 cluster=$4 principal=$5 namespace=$6
[[ $action == plan || $action == apply ]] || exit 2
[[ $principal =~ ^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9/+=,.@_-]+$ && $namespace =~ ^[a-z0-9][a-z0-9-]*$ ]] || exit 2
command -v aws >/dev/null
command -v jq >/dev/null
mode=$(aws --profile "$profile" --region "$region" eks describe-cluster --name "$cluster" --query cluster.accessConfig.authenticationMode --output text)
[[ $mode == API || $mode == API_AND_CONFIG_MAP ]] || { printf 'Enable EKS access entries through your reviewed cluster lifecycle workflow first.\n' >&2; exit 1; }
printf 'Grant AmazonEKSEditPolicy to the selected role in namespace %s only.\n' "$namespace"
[[ $action == apply ]] || exit 0
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
if ! aws --profile "$profile" --region "$region" eks describe-access-entry --cluster-name "$cluster" --principal-arn "$principal" > "$workspace/entry.json" 2> "$workspace/error"; then
  if ! grep -q 'ResourceNotFoundException' "$workspace/error"; then cat "$workspace/error" >&2; exit 1; fi
  aws --profile "$profile" --region "$region" eks create-access-entry --cluster-name "$cluster" --principal-arn "$principal" --type STANDARD >/dev/null
fi
aws --profile "$profile" --region "$region" eks associate-access-policy \
  --cluster-name "$cluster" --principal-arn "$principal" \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy \
  --access-scope "type=namespace,namespaces=$namespace" >/dev/null
printf 'Applied. Existing grants were not removed; audit all associated policies for broader access.\n'

