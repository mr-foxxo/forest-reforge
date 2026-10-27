# Decision register: reconcile before automating

These decisions govern the generic guides. Historical files preserve conflicting statements under an archive warning.

| Topic | Conflicting evidence | Canonical documentation choice |
|---|---|---|
| Hosts | Solis / node-ctl naming versus Deerly/Foxy/core | Generic hv01/hv02 and core-*; old names remain history |
| Node network | Planning has 172.16.4.8–12; operational inventory has 172.16.3.20+ | New-build example uses Servers subnet; actual site must be discovered |
| API VIP | Earlier hostname-first bootstrap versus kube-vip | Example 172.16.3.30; reserve before assigning nodes |
| Gateway VIP | 172.16.3.200 throughout later documents | Retain example, require same-L2 announcers |
| CNI | Calico in early installation | Cilium and kube-proxy replacement |
| Control plane | 3 nodes in early plan; 5 in expansion | Start with 3, expand only for a justified quorum design |
| TLS DNS provider | Route 53 first; Cloudflare after DNS cutover | Cloudflare branch is later operational path; Route 53 remains alternative |
| Edge publication | Earlier Argo + Backstage | Initial publication is Backstage only |
| Router administration | Older broad wg-admin statements | Only wg-paws-access; deny wg-admin to every router-local management address |
| Paws DNS access | DNS-only versus all RPi services | All services on dns01 only, not all Infra |
| Identity | Keycloak discussed; later GitHub-only baseline | GitHub org + Access + Backstage auth; Keycloak optional future ADR |
| Argo auth | Local-first prose versus github-dex variable | Verify actual mode; local recovery retained, Dex opt-in |
| Backstage DB | External VM PostgreSQL in plan; managed StatefulSet in runbook | Document both; runbook path uses dedicated LocalPV database, with its risk |
| Registry | GHCR plan versus ECR runbook | ECR is operational source path; GHCR is an explicit alternative |
| Image tags | Mutable latest in runbook versus immutable builds | New public recipe requires digest/pinned immutable image |
| AWS environments | Earlier dev/staging/prd summary | EKS runbook explicitly has dev active, prd dormant, no staging |
| AWS account topology | Early account-per-environment ambition | Forest/FoxByte target accounts supported by evidence; do not invent deployed OU/account IDs |
| ESO and logging | Named in architecture but backend/versions deferred | Planned until actual installation evidence exists |
| ExternalDNS | RFC2136 planned; bootstrap says not installed | Manual records until explicit ownership handoff |
| P4 vGPU | Historical branch 19.4 ambition | Official P4 ceiling is branch 16; 19.x path is not supported |
| V100 vGPU | Branch 19 planned | Vendor lists branch 19; exact kernel/driver/guest still needs qualification |
| M40 vGPU | Family similarity could imply support | No official support; do not confuse M40 with M60; originating chat deferred M40 work |
| Added GPU export | Earlier 19.4 ambition versus final specific recipe | P4 16.14/535.309.01 host milestone source-reported; guest result pending |
| Added DRAC5 export | Unknown keyboard option / manual versus automatic JNLP | i386 JNI and keyboard option confirmed; credential-only fetcher proposed, not demonstrated |

## Superseded commands

The original reset guide flushes firewall state and deletes storage. It is retained for history but excluded from the normal build path. The current cleanup procedure targets dedicated test resources only.

Historical chart pins are evidence of a prior configuration. They are not a promise of availability or compatibility today. Resolve an exact stack once, then record it; never silently replace pins with `latest`.

## Open decisions

Record physical rack measurements; settle real node addressing; confirm installed GPU identities; qualify a complete stack per GPU; select external secrets backend; define backup RPO/RTO; choose durable DB/storage placement; approve identity federation only if required; establish AWS endpoint routing and production activation criteria.
