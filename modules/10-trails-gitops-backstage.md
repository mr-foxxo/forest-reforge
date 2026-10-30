# 10 · Trails — GitOps and developer portal

[English (default)](10-trails-gitops-backstage.md) | [Português (Brasil)](../docs/pt-BR/modules/10-trails-gitops-backstage.md) | [Documentation index](../docs/README.md)

The [versioned Argo runtime screenshot](../docs/den-validations-experiments.md#argo-cd-runtime) shows component CPU/memory metrics and running-pod counts, including two server and two ApplicationSet pods. This complements the configuration contracts below with runtime evidence. Application sync, destination rejection and sign-in outcomes belong in the corresponding functional records.

Automation: `trails` supplies Argo projects/root application and optional GitHub Dex; `backstage` supplies configuration, app and route. The [automation guide](../docs/automation.md) defines image, database and ownership contracts.

## Repository boundaries

| Repository | Responsibility |
|---|---|
| forest-reforge | Public documentation and qualification examples |
| Private infrastructure implementation | Inventory, bootstrap roles, external resources, secret delivery |
| GitOps repository | Desired Kubernetes runtime state per cluster |
| Backstage application repository | Plugins, source, container build, catalog/scaffolder behavior |

Ansible owns the initial root Application. Argo owns child Applications/AppProjects and transferred workloads. Record object-by-object ownership, including namespaces and bootstrap credentials.

## Bootstrap Argo

1. Install a pinned Argo chart after networking, storage and TLS work.
2. Set its canonical private URL and configure Gateway termination deliberately. If the server runs HTTP behind TLS termination, restrict that internal path; do not expose its insecure port publicly.
3. Rotate initial admin credentials and retain controlled local recovery. Enable GitHub/Dex SSO only when roles and membership mappings are ready.
4. Install repository credentials from a GitHub App with minimum repository access. Keep its key/installation data outside Git.
5. Create a root Application targeting a `bootstrap` directory with limited AppProjects and children. Validate repository authentication and render before enabling automated pruning.
6. Restrict source repositories, destinations, namespace resources and cluster-scoped resources. AppProject boundaries complement Kubernetes RBAC; they do not replace it.
7. Sync a disposable application and remove it deliberately. Confirm a wrong namespace/cluster destination is rejected.

## Logical GitOps paths

- `bootstrap/`: AppProjects and child Applications.
- `clusters/den/platform/`: transferred platform components.
- `clusters/den/applications/`: local application workloads.
- `clusters/forest-dev/` and `clusters/foxbyte-dev/`: active cloud targets.
- `clusters/forest-prd/` and `clusters/foxbyte-prd/`: dormant plans; no active children by default.

These are documented conventions, not a complete manifest tree in this edition.

## Build Backstage

1. Generate/build an app using the selected official Backstage pattern. Record Node/package-manager versions and lockfile.
2. Add GitHub auth, organizational catalog ingestion and required integration modules; add Kubernetes/TechDocs/scaffolder plugins only as needed.
3. Configure one canonical app/backend base URL, matching CORS/callback paths and Gateway hostname.
4. Configure the selected PostgreSQL placement, database/user, backend secret and GitHub credentials through named Secret references.
5. Build and scan an immutable image; push to ECR (operational source path) or an explicitly chosen registry. Record digest and provenance.
6. Prepare namespace and runtime secrets through bootstrap. Render non-secret manifests for review; place Deployment, Service, ConfigMap, HTTPRoute, PDB and policy under Argo ownership.
7. For the source managed-DB option, Argo also owns a dedicated PostgreSQL StatefulSet/Service/PVC. Add DB backup and recovery before treating it as durable.
8. Sync; verify startup, probes, database migrations, catalog ingestion and login. Probe the application locally, not through the public Access challenge.

The source app port is 7007. Validate health endpoints against the built application; do not copy an endpoint from another Backstage generation.

## ECR pull credentials

ECR authorization tokens expire after 12 hours. A successful first pull does not make a months-old imagePullSecret viable. Until an automatic refresh mechanism exists, refresh before restarts and monitor expiry; then adopt a properly scoped refresher/credential mechanism. A running pod does not validate future image pulls.

Do not ship the source runbook's mutable `latest` default in a reproducibility recipe. Keep immutable image references and an explicit previous digest for rollback.

## Portal integration and golden path

Import GitHub users/teams and repository catalog entities. Resolve every `spec.owner` to an imported Group. Use a separate read-scoped Kubernetes ServiceAccount for the portal plugin; do not give the portal cluster-admin.

The future scaffolder flow: select owner/template → create repository → CI builds immutable image → propose GitOps change → authorized review → Argo reconciles → catalog shows workload and observability links. Require approval boundaries for privileged infrastructure generation. Backstage is not a universal credential proxy.

Acceptance: named user maps to correct catalog identity; forbidden template/action is denied; image digest matches; DB survives pod replacement; rollback digest runs; Argo self-heals only resources it owns.
