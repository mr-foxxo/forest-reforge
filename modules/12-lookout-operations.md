# 12 · Lookout — operate and recover

Automation: `lookout` installs monitoring and optional logging/secrets controllers; `backup` schedules [etcd-backup.sh](../scripts/etcd-backup.sh). [cluster-troubleshoot.sh](../scripts/cluster-troubleshoot.sh) collects layer-specific conditions without Secret contents. See the [recovery guide](../docs/automation.md).

## Observe the whole chain

The source baseline installs kube-prometheus-stack with Grafana, Prometheus, Alertmanager, node exporter and kube-state-metrics. Hubble covers cluster network visibility. Loki + Alloy are a planned GitOps stack with versions, retention and storage still to be chosen.

Monitor hardware temperature/ECC/disk faults, host pressure, VM resource contention, Kubernetes capacity, API/etcd health, Cilium drops, VIP availability, certificate lifetime, DB/storage space, Argo sync, tunnel health, image-pull failures and backup age. GPU exporters must be checked against the legacy card/driver; no DCGM compatibility is assumed here.

Use bounded log labels (cluster, namespace, app); do not turn request IDs or user identifiers into unbounded label cardinality. Protect logs from tokens and credentials. Choose retention from measured ingestion/storage cost. An empty chart version in the source is a deferred decision, not a deployable default.

## Backup scope

| Asset | Required recovery material | Test |
|---|---|---|
| Router/DNS | Configuration, zone data, TSIG/VPN secrets privately | Recover routing/name service offline |
| Hypervisor | Host/VM config, storage layout, guest backups | Restore test VM to available host |
| Kubernetes | etcd snapshot + PKI + encryption config + kubeadm/kube-vip state | Isolated control-plane restore |
| GitOps | Repository, credentials recovery, pinned artifacts | Recreate controller and sync |
| PostgreSQL | Logical/physical backup + roles + required keys | Restore and query expected rows |
| Object storage | Data + metadata + version/retention policy | Restore sample object and checksum |
| Identity | Recovery accounts, provider config and key access | Login during primary IdP outage |

A local etcd timer is only the first stage. Copy backups off-cluster, encrypt them, check integrity and retain a separately recoverable key. Store at least one copy outside the host/rack failure domain. Define actual RPO/RTO targets; this repo does not invent business requirements.

## Restore order

1. Physical power and network reachability.
2. Independent DNS, time and owner recovery access.
3. Hypervisor/storage and essential data-service guests.
4. Kubernetes control plane with matched backup and encryption/PKI material.
5. Cilium/Gateway/certificates and bootstrap secrets.
6. Argo and runtime reconciliation.
7. Stateful restore, portal and workloads.
8. Cloud integrations and external access, followed by security and data checks.

Use an isolated environment for restore drills to avoid duplicate VIPs, duplicate controllers and stale credentials acting against production. Etcd restores require the chosen Kubernetes/etcd version's documented membership procedure; never restore by copying a random live data directory.

## Maintenance cadence

Per change: inventory diff, backup, version pin, one-node canary, workload test and rollback. Weekly example: backup freshness, disk/thermal errors, certificate and token expiry. Monthly example: restore sample, patch evaluation, cost review and access membership review. These are suggested operator cadences, not scheduled tasks created by this package.

## Cleanup

Use dedicated namespaces for smoke tests. Inspect the namespace and its PVCs before deletion, and record expected data loss. Do not flush host iptables or delete `/var/openebs` to clean up a failed HTTPRoute. Uncordon only nodes cordoned by your interrupted test, not every node globally.

Keep the recovery runbook accessible outside Backstage. If losing the portal also loses the instructions and credentials needed to restore it, the architecture has a circular dependency.
