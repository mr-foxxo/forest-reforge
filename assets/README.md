# Public evidence images

These two original dashboard screenshots were individually reviewed and copied unchanged from the private evidence set. They contain resource metrics and standard platform component names. Private account information, hostnames, addresses and sign-in overlays in the other source views remain outside the versioned/public assets.

| Asset | Scope | Documentation |
|---|---|---|
| [cluster_resources.png](cluster_resources.png) | Cluster CPU/memory utilization and resource commitment; namespace metrics | [Den validations and experiments](../docs/den-validations-experiments.md#monitoring-and-cluster-resources) |
| [workloads.png](workloads.png) | Argo CD workload CPU/memory metrics and visible running-pod counts | [Argo runtime record](../docs/den-validations-experiments.md#argo-cd-runtime) |

[evidence.json](evidence.json) records image checksums, review date and scope. The original pixels are preserved: no generated or reconstructed values are used. Each dashboard retains its own filters, sampling window and units. The [platform record](../docs/den-case-study.md) relates these images to the host and node baseline.

The release packager includes public assets and excludes the private `reference/` and `local/` trees. Add future screenshots only after reviewing visible content and metadata; keep private originals and provenance separately.
