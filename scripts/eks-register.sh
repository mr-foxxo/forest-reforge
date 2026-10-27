#!/usr/bin/env bash
# Registration does not grant AWS permissions or supply the Argo runtime identity.
set -Eeuo pipefail
umask 077
if [[ ${1:-} == --help ]]; then
  printf 'Usage: eks-register.sh plan|apply CONTEXT AWS_PROFILE REGION CLUSTER ROLE_ARN NAMESPACES\nNAMESPACES is comma-separated. Runtime Argo AWS credentials and EKS access must already exist.\n'
  exit 0
fi
[[ $# == 7 ]] || exit 2
action=$1 context=$2 profile=$3 region=$4 cluster=$5 role=$6 namespaces=$7
[[ $action == plan || $action == apply ]] || exit 2
[[ $cluster =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ && $role =~ ^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9/+=,.@_-]+$ && $namespaces =~ ^[a-z0-9-]+(,[a-z0-9-]+)*$ ]] || exit 2
for tool in aws kubectl jq; do command -v "$tool" >/dev/null; done
workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
aws --profile "$profile" --region "$region" eks describe-cluster --name "$cluster" --output json > "$workspace/cluster.json"
jq -e '.cluster.status == "ACTIVE" and (.cluster.endpoint | startswith("https://")) and (.cluster.certificateAuthority.data | length > 0)' "$workspace/cluster.json" >/dev/null
jq --arg name "$cluster" --arg role "$role" --arg region "$region" --arg namespaces "$namespaces" '
  {apiVersion:"v1",kind:"Secret",type:"Opaque",metadata:{name:("eks-" + ($name|ascii_downcase|gsub("_";"-"))),namespace:"argocd",
    labels:{"argocd.argoproj.io/secret-type":"cluster","app.kubernetes.io/managed-by":"reforge-bootstrap"}},
   stringData:{name:$name,server:.cluster.endpoint,namespaces:$namespaces,clusterResources:"false",
     config:({execProviderConfig:{command:"argocd-k8s-auth",args:["aws","--cluster-name",$name,"--role-arn",$role],
       apiVersion:"client.authentication.k8s.io/v1beta1",env:{AWS_REGION:$region,AWS_DEFAULT_REGION:$region}},
       tlsClientConfig:{insecure:false,caData:.cluster.certificateAuthority.data}}|tojson)}}' \
  "$workspace/cluster.json" > "$workspace/registration.json"
if [[ $action == plan ]]; then
  printf 'Registration preview (keep endpoint and account metadata private):\n'
  jq . "$workspace/registration.json"
else
  kubectl --context "$context" apply --server-side --field-manager=reforge-bootstrap -f "$workspace/registration.json"
fi

