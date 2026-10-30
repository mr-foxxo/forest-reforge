# 11 · Skybridge — AWS accounts and hybrid delivery

[English (default)](11-skybridge-aws.md) | [Português (Brasil)](../docs/pt-BR/modules/11-skybridge-aws.md) | [Documentation index](../docs/README.md)

Helpers: [eks-access.sh](../scripts/eks-access.sh), [eks-register.sh](../scripts/eks-register.sh), [ecr-refresh.sh](../scripts/ecr-refresh.sh) and [IAM examples](../automation/aws/deployer-trust.example.json). Read the [runtime identity and explicit-target requirements](../docs/automation.md) first.

## Scope supported by the sources

Two organization/business scopes are named Forest and FoxByte. Operational EKS targets are `forest-dev` and `foxbyte-dev`, with production paths dormant and **no staging**. Earlier conversations proposed broader OU/account-per-environment layouts; no complete deployed Organizations inventory was supplied.

Do not infer one AWS account per environment from cluster names. Record the actual account, region and role for every cluster. The public examples use fictional account IDs and `us-east-1` as the source default.

## Account foundation

1. Inventory existing Organizations, OUs, accounts, owners and billing contacts before creating duplicates.
2. Separate organization administration from workload deployment. Protect root recovery/MFA and use short-lived human access through the chosen AWS identity setup.
3. Map Forest/FoxByte workload accounts and environments explicitly; reserve production activation as a separate reviewed change.
4. Establish audit logging, budgets and tags. Choose guardrails/SCPs based on actual required services and test their effect in dev.
5. Create per-target deployment roles and per-workload service identities. Never grant broad organization administration merely to deploy a namespace.

AWS charges can accrue while the den is idle: EKS control planes, NAT gateways, VPNs, load balancers, logs, snapshots and storage. Record cost ownership and a teardown/retention decision before enabling optional services. No current price claims are embedded in this guide.

## Network integration

The earlier design favored Site-to-Site VPN to a VPC Virtual Private Gateway, peering for selected VPC relationships, and avoiding Transit Gateway initially. Treat that as a design constraint to validate, not evidence of working routes.

1. Allocate non-overlapping VPC/LAN/VPN/pod/service ranges; record which prefixes cross the VPN.
2. Configure customer gateway, VPN tunnels and VGW attachment using the actual public endpoint and routing mode. Preserve both tunnel states and test failover.
3. Add intended VPC and den routes plus return routes. Restrict security groups and local firewall rules to the service identity/source ranges observed on the wire.
4. Choose EKS API endpoint access mode. A private API requires den routing and DNS resolution; a public endpoint with restrictions requires a stable permitted egress address.
5. Account for MTU and name resolution across VPN; test an HTTPS API call, not only ICMP.

**VPC peering is not transit.** Do not assume den→VGW in VPC A→peering→VPC B provides VPN access to VPC B. Design direct supported connectivity per target, an explicitly supported routing appliance arrangement, or reassess Transit Gateway when transit is required. Document DNS resolver forwarding/endpoints separately.

## Cross-account Argo authentication chain

On-prem Argo is not an EKS pod and does not automatically receive EKS Pod Identity or IRSA. Choose an explicit on-prem credential delivery mechanism. Static base keys in Vault are a source-reported bootstrap fallback; prefer renewable short-lived identity where available and qualify it with the selected Argo auth helper.

The chain is: Argo base identity → STS AssumeRole in target account → EKS token → target cluster Access Entry → namespace/resource authorization. Every link needs an independent test.

1. Allow the source principal to assume the exact target role ARN.
2. Make the target role trust that source principal. Both identity policy and trust must allow the operation.
3. Create an EKS STANDARD Access Entry for the target role, using a cluster authentication mode that supports access entries.
4. Associate a namespace-scoped suitable access policy or mapped Kubernetes RBAC groups. Grant cluster-scoped permissions separately only when required.
5. Discover endpoint and CA using the designated read-only/discovery profile. Do not confuse this local profile with the identity used by Argo at runtime.
6. Create the Argo cluster Secret privately with endpoint, CA and the selected `argocd-k8s-auth aws` exec configuration, including region/cluster/target role as required by the installed Argo version. Verify that helper exists in the running image.
7. Restrict AppProject destinations and resource types independently.
8. Deploy a disposable namespaced workload, then prove a forbidden namespace/cluster action is denied.

The public edition deliberately does not contain generated cluster Secrets or AWS keys.

## Diagnostics (private shell/session)

```bash
aws sts get-caller-identity --query Arn --output text
aws eks describe-cluster --name forest-dev --region us-east-1 \
  --query 'cluster.{endpoint:endpoint,status:status}'
aws sts assume-role \
  --role-arn arn:aws:iam::111122223333:role/argocd-forest-dev-deployer \
  --role-session-name reforge-diagnostic \
  --query AssumedRoleUser.Arn --output text
```

Use the same credential context as the failing component. These selected outputs omit temporary secret credentials; do not paste raw AssumeRole responses publicly.

`SignatureDoesNotMatch`: verify the source access-key pair, secret value, clock and session-token consistency. The source notes observed an invalid secret surfacing as `argocd-k8s-auth` exit 20/timeouts. `AccessDenied` during assumption: inspect both IAM sides. Successful STS but forbidden Kubernetes: inspect Access Entry/RBAC. Timeouts reaching EKS: investigate routing/DNS/endpoint restrictions before IAM.

## ECR and AWS workloads

Separate registry pulls from application AWS API access. Scope `ecr:GetAuthorizationToken` as required and restrict repository data-plane actions to intended repos. Rotate/refresh credentials and pull tokens. Use workload-specific Secrets/identities rather than copying a broad Forest principal into every namespace.

GitHub Actions can use an OIDC trust restricted to the intended repository/ref/environment for cloud delivery; that is an implementation option, not evidence it already exists here. Do not give untrusted pull-request jobs access to den networks or deployment credentials.

References: [EKS access entries](https://docs.aws.amazon.com/eks/latest/userguide/creating-access-entries.html), [Argo declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/), [VPC peering limitations](https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html).
