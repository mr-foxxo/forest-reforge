# Decision register: reconcile before automating

[English (default)](decisions.md) | [Português (Brasil)](pt-BR/decisions.md) | [Documentation index](README.md)

These decisions govern the generic guides. Historical files preserve conflicting statements under an archive warning.

| Topic | Conflicting evidence | Canonical documentation choice |
|---|---|---|
| Hosts | Solis / node-ctl naming versus Deerly/Foxy/core | Generic hv01/hv02 and core-*; old names remain history |
| Node network | Planning has 172.16.4.8–12; operational inventory has 172.16.3.20+ | New-build example uses Servers subnet; actual site must be discovered |
| API VIP | Earlier hostname-first bootstrap versus kube-vip | Example 172.16.3.30; reserve before assigning nodes |
| Gateway VIP | 172.16.3.200 throughout later documents | Retain example, require same-L2 announcers |
| CNI | Calico in early installation | Cilium and kube-proxy replacement |
| Cluster scale | Earlier plans/counts differ; latest node screenshot shows 5 control planes + 8 workers, all Ready at v1.36.4 | Preserve observed scale in a separate example; retain smaller new-build default; five voters on two physical hosts do not imply host-resilient quorum |
| Hypervisor membership | Four Proxmox panels; owner explicitly excludes two from Kubernetes hosting | Only hv01/hv02 count toward Kubernetes host capacity; hv03/hv04 remain integrated infrastructure |
| VM placement and quorum | Follow-up guest trees now resolve placement previously left open | hv01 hosts cp01–03/wk01–04; hv02 hosts cp04–05/wk05–08; conditional five-voter quorum is asymmetric across the two standalone hosts |
| Discovery versus GPU execution | Node-feature-discovery metrics now visible on core-cp01 | Record discovery component activity; keep GPU device allocation, licensing and CUDA/model results separate |
| Current RAM | Older 196 GB description and mixed-memory history versus current panels | Use displayed 125.87/62.65 GiB for Kubernetes hosts; do not invent current DIMM populations or per-guest sizes |
| Resource scope | Worker dashboard could be mistaken for whole-cluster capacity | 64 CPU / 124.1 GiB allocatable and 116 pods are worker-only observations |
| NAS | Old inventory-only NAS entry versus current TrueNAS dashboard | Two ONLINE single-disk pools now observed; exports, redundancy and restore remain unproven |
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
