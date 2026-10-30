# Reference-to-automation map

[English (default)](automation-source-map.md) | [Português (Brasil)](pt-BR/automation-source-map.md) | [Documentation index](README.md)

This map records how the supplied material informs the generic implementation. All new automation uses `reforge_*` variables, role-based hostnames, example domains, documentation-only IPs and dummy account IDs. No original inventory, vault, application artifact or private API label is imported. The source tree stays local and is excluded from the release helper.

| Evidence | Portable implementation | Deliberate boundary |
|---|---|---|
| Source notes 01, 06, 07, 10, 11; common/control-plane/worker roles | Roots and Canopy; pinned CRI/packages, kubeadm v1beta4, Secret encryption, API VIP, serial joins | No old Calico path, hard-coded subnet detection, curl-to-shell Helm install or cluster reset |
| Source notes 18, 24; node-expansion runbooks | Existing-node detection, source control-plane discovery, short-lived tokens, certificate transfer | Full private inventory required; no fabricated physical topology |
| Source notes 23, 25; Cilium/Gateway roles | Explicit interfaces and LB pool, CRDs before CNI, Gateway-scoped L2 policy | Portable VXLAN baseline; native routing/encryption needs separate qualification |
| Source notes 03, 26; DNS/cert-manager/platform-Gateway roles | Optional independent DNS, Cloudflare DNS-01, staging-first ACME, shared Gateway | No registrar/DNS authority migration; no global DNS API key |
| Source notes 09, 19, 20; storage/security/secrets roles | LocalPV Retain class, PSA/default-deny namespace policies, protected runtime Secrets, optional ESO controller | No automatic disk erasure, no fictional secret backend, no LocalPV HA claim |
| Source notes 04, 05, 15; Argo bootstrap roles | GitOps root at explicit commit, scoped projects, private service and optional GitHub Dex | Root trusted to platform admins; runtime workloads have no blanket cluster grants |
| Source notes 09, 16, 21, 22; identity/Backstage roles | Separate OAuth credentials, org catalog + ID resolver, external DB TLS, reviewed application image | No Keycloak dependency, guest auth bypass or assumption that Access is app authorization |
| Source notes 12, 21, 22, 26; edge roles | Backstage-first publication, two fixed cloudflared replicas, readiness, scoped origin/egress | No infrastructure tunnel routes, no WAN forwarding or disabled origin TLS verification |
| Source notes 13, 14; EKS/AWS access roles | Named profiles, namespace access entries, declarative Argo cluster Secret, ECR renewal and IAM examples | Runtime workload identity must be supplied; dormant production is never auto-enabled |
| Source notes 02, 08, 17; acceptance/logging/backup roles and recovery docs | Read-only layer diagnostics, monitoring, optional explicit logging values, etcd snapshot/critical files/systemd timer | No broad namespace cleanup, firewall flush, destructive reset or untested automatic restore |
| Full GPU chat and curated R710/P4 runbook | Burrows/Embers prerequisites, BDF-scoped diagnosis, kernel artifact gate, checked installer extraction, stopped-VM native-profile attachment | No fabricated kernel patch, copied profile number, unsupported official-support claim or license bypass |
| Full DRAC5 chat and curated console runbook | Isolated linux/386 JDK/JNI viewer, fresh private JNLP, loopback/password VNC, persisted keyboard preference | Missing historical ZIP is not reproduced as tested; no claimed automatic browser login |
| Module 13 and GPU architecture constraints | Pinned-checkout Spellwork CMake helper with explicit 52/61/70 target and legacy CPU options | A build is not a measured model result; toolchain/revision must retain the selected kernels |

The [decision register](decisions.md) remains authoritative for conflicts in the history. The new automation provides concrete bootstrap implementations where the earlier edition had only contracts. Logging/ESO can now be installed deliberately, but backend, retention and ownership decisions remain explicit. Do not combine this implementation with the old playbooks on the same live objects.

The seven-image baseline and ten follow-up Den views are reconciled in the [case study](den-case-study.md), [experiment ledger](den-validations-experiments.md) and [machine-readable profile](../examples/observed-platform.json). They establish inventory/resources, infrastructure-only hosts, VM placement, standalone host topology and selected runtime metrics. Two clean originals are versioned through the [public asset manifest](../assets/evidence.json). The [observed-size inventory](../automation/ansible/inventory.observed.example.yml) uses documentation addresses and placement metadata; [cluster-resources.py](../scripts/cluster-resources.py) checks Node data without mutating a running cluster. Functional experiments retain their own result records.
