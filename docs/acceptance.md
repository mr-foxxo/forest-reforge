# Acceptance, rollback and release evidence

[English (default)](acceptance.md) | [Português (Brasil)](pt-BR/acceptance.md) | [Documentation index](README.md)

The [platform record](den-case-study.md) establishes hardware/version fields, ONLINE NAS pools and 13 Ready Kubernetes nodes, with worker-only totals. Follow-up [validations and experiments](den-validations-experiments.md) add VM placement, standalone hypervisor topology, Grafana resource metrics, selected-node sizing and Argo runtime counts. The ledger separates each collected result from the functional test that follows it. Failover, restore, network/identity rejection, CUDA/model execution and fresh bootstrap reproduction use the gates below.

| Gate | Positive test | Negative/failure test | Evidence |
|---|---|---|---|
| Physical | Stable load temperatures/power | Controlled cooling/shutdown response | Measured record |
| Memory | Final population passes repeated tests | Reproduce suspect stick/slot result | Test matrix |
| Router policy | Paws manages router | wg-admin cannot reach management on any router IP | Firewall counters + client result |
| DNS boundary | Paws reaches all intended dns01 services | Human admin lacks ungranted Infra access | Connection matrix |
| Hypervisor | Restore disposable VM | Boot preserved kernel after failed canary | Restore log |
| GPU | Real CUDA/model workload | Unsupported stack rejected/documented | Full version tuple |
| Kubernetes | API, nodes, DNS, cross-node traffic | One-at-a-time failover test | Conditions and timing |
| Gateway | TLS succeeds from LAN/VPN | Wrong host not routed | HTTP/TLS result |
| Storage | Sentinel persists on intended node | Restore from independent backup | Checksum/data query |
| Identity | Authorized catalog user logs in | Outsider/removed member denied | Redacted auth outcome |
| GitOps | Commit syncs scoped object | Wrong destination denied | Argo event + RBAC result |
| AWS | STS + EKS + scoped deployment | Forbidden namespace denied | Principal/result, no credentials |
| Recovery | Isolated full restore | Primary portal/IdP unavailable | RPO/RTO measurements |

## Test sequence

Run read-only inspection first, then dedicated disposable resources, then disruptive tests in a maintenance window. Capture baseline resource names and who owns them. Create a dedicated namespace such as `reforge-smoke` and verify it contains only disposable data before deletion.

Do not equate all pods Running with a complete gate. Gateway reachability must be tested outside the cluster; cloud auth must be tested with the runtime principal; backups must be restored.

## Rollback record

For every mutating change record: pre-change versions/config, known-good boot path, affected workloads, expected downtime, backup location, precise reversal, and post-rollback acceptance. Keep that record available outside the system being changed.

## Package validation versus deployment validation

Repository validation covers links, syntax, templates, offline behavior and archive exclusions. `cluster-resources.py --context YOUR_CONTEXT --expect examples/observed-platform.json` additionally checks current Node inventory/readiness and aggregate worker capacity against the reviewed snapshot. It does not check Pod requests/metrics, placement, services or recovery. A difference from the snapshot can be a deliberate capacity/version change. Promote a complete stack to locally validated only with the [stack record](../examples/validated-stack.md) and the relevant functional results.
