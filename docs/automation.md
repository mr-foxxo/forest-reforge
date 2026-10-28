# Forest Reforge automation

This iteration adds portable Ansible roles, service configurations and operational helpers derived from the supplied on-prem implementation and both chat exports. It is a **proposed implementation with offline validation**, not a deployed-stack record. Nothing loads configuration from `reference/`. The [source map](automation-source-map.md) records the design choices carried forward.

## Existing platform: inspect before changing

The [evidence reviewed on 2026-10-28](den-case-study.md) shows 5 control planes and 8 workers Ready at kubelet v1.36.4. The [snapshot](../examples/observed-platform.json) records worker-only capacity and four hypervisor panels; two hypervisors host Kubernetes guests and two are infrastructure only. Follow-up guest trees now establish placement, and the [experiment ledger](den-validations-experiments.md) adds runtime metrics and public screenshots. Bootstrap/runtime/chart version pins still come from the private site contract.

Use `python scripts/cluster-resources.py --context YOUR_CONTEXT --expect examples/observed-platform.json` from the prepared controller for a read-only comparison. It reads only Nodes and emits generic aggregates. It also accepts a private `--nodes-json` export. See the [case study](den-case-study.md) for output/exit-code scope. Do not run `roots`, `canopy` or `main.yml` against a working cluster just to validate these screenshots: those phases own OS/runtime/bootstrap configuration.

The [observed-size inventory](../automation/ansible/inventory.observed.example.yml) is an alternative to the smaller new-build inventory. Copy one example deliberately; both use documentation-only addresses and remain unreviewed by default. `kubernetes_hypervisors` and `infrastructure_only_hypervisors` are separate children of `burrows`; only guest nodes belong to `canopy`. The infrastructure-only hosts remain eligible for explicitly selected hypervisor maintenance, not automatic Kubernetes joins. `reforge_hypervisor` records the observed guest placement as metadata, without provisioning or migrating VMs.

Use the screenshot's v1.36.4 as an observed kubelet version, not proof of the API server, Debian package revision, containerd version, driver or chart pins. Leave those fields unresolved until exported/qualified privately. Generic role names are example identifiers; do not rename live nodes to adopt them. For adoption, reconcile existing ownership/configuration and collect the missing functional evidence before choosing which roles should manage the system.

## Controller and private contract

Use a Linux/macOS controller with Bash, Python 3.11+, Helm 3, kubectl and SSH; release packaging also uses rsync and tar. Cloud helpers require AWS CLI v2 and jq. Nodes must be dedicated systemd Debian/Ubuntu guests with Kubernetes 1.31+ for kubeadm v1beta4. The runtime role supports distribution **containerd 1.x** only; qualify containerd 2.x separately. Hypervisor work targets a separate `burrows` inventory group.

From the repository root:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r automation/controller-requirements.txt
ansible-galaxy collection install -r automation/ansible/requirements.yml
mkdir -m 700 -p local
cp automation/ansible/inventory.example.yml local/inventory.yml
cp automation/ansible/site.example.yml local/site.yml
cp automation/ansible/secrets.example.yml local/secrets.yml
```

Edit the private files, then run `ansible-vault encrypt local/secrets.yml`. Set `reforge_inventory_reviewed: true` after reviewing the inventory. Examples contain documentation addresses and empty release pins. Keep vault passwords outside the repository, preserve SSH host verification and keep run output private. Do not use `--diff` on secrets or publish Helm release data, kubeconfigs or backups.

| Contract | Required choices |
|---|---|
| Addressing | Node IPs/NICs, independent DNS, reserved API/Gateway IPs, non-overlapping pod/service/LB ranges; API name resolves to VIP from every node |
| Versions | Kubernetes minor/upstream version/exact package version, containerd package version, pause/kube-vip digests, chart versions, Gateway API release URL and independently checked SHA-256 |
| Recovery | Existing console access, off-host backup destination/SSH trust, etcdctl and etcdutl matching the cluster's etcd minor |
| Encryption | Generate `openssl rand -base64 32` once, put it in the private vault and back it up separately; never regenerate on rerun |
| Controller | One absolute `reforge_kubeconfig` path and matching `reforge_kube_context`; no ambient merged context |
| Services | A real delegated DNS zone, scoped Cloudflare token, ACME email, explicit storage class, GitOps URL/full commit SHA |

The Kubernetes package version must match the upstream version. Choose a mutually compatible tuple using the [version record](../examples/validated-stack.md). Controller and collection pins are in `automation/`; these do not certify target versions. Nodes must have Python and sudo access before Ansible can prepare them.

## Phases and checkpoints

The wrapper requires explicit files and one named phase. `plan` uses Ansible check mode: it may contact hosts and run read-only inspections, and cannot simulate packages or CRDs that do not exist yet. It is a partial preview. Apply one phase and validate before continuing.

```bash
bash scripts/reforge.sh plan roots local/inventory.yml local/site.yml
bash scripts/reforge.sh apply roots local/inventory.yml local/site.yml
bash scripts/reforge.sh apply canopy local/inventory.yml local/site.yml local/secrets.yml
```

| Phase | Configuration | Checkpoint / recovery |
|---|---|---|
| `names` | Optional independent dnsmasq, no DHCP | Test TCP/UDP DNS; restore config backup if needed |
| `roots` | Swap, modules/sysctls, pinned CRI/Kubernetes packages, holds, systemd cgroups | Runtime responds; restore guest snapshot for rollback |
| `canopy` | Encrypted kubeadm init, API kube-vip, sequential joins | API reachable; nodes await CNI; investigate failed joins without resetting existing members |
| `paths` | Checked Gateway CRDs, Cilium replacement for kube-proxy, L2 pool/policy | Nodes Ready, Cilium health, same-L2 ARP and connectivity |
| `vault` | OpenEBS LocalPV and non-default `Retain` StorageClass | Test scheduled PVC consumer and data restore; no formatting |
| `gatehouse` | cert-manager, Cloudflare DNS-01, shared HTTPS Gateway | Staging challenge/certificate first; production only after verification |
| `trails` | Argo CD, optional GitHub Dex, scoped projects/root app | Port-forward, allowed/rejected users, destination restrictions |
| `lookout` | Persistent monitoring, optional ESO/Loki/Alloy | Inspect PVCs/targets, configure alert delivery; private logging values required |
| `baseline` | Restricted PSA, default deny and DNS allowance | Application-specific policies and positive/negative path tests |
| `backstage` | GitHub auth/catalog, PostgreSQL config, app/route/policy | DB recovery, catalog identity, rejected login and app permissions |
| `edge` | One tunnel, two fixed connectors | Access policy verified first, Gateway SNI/TLS, external rejection |
| `backup` | Per-control-plane snapshot service/timer | Trigger a run, verify off-host copy and isolated restore |
| `burrows` | Selected Proxmox bootloader IOMMU config | Console recovery, later reboot, groups; restore config and regenerate boot files |
| `embers` | Exact headers, build tools, optional pinned packaged drivers | Module/signature/profile tests; restore prior qualified tuple |

`main.yml` assembles the cluster phases but excludes DNS host changes, hypervisors, Backstage and edge. Prefer individual phases for the first deployment. It requires all core inputs and a usable controller kubeconfig.

For `names`, add `reforge_dns_listen`, `reforge_dns_upstreams`, and `reforge_dns_records` (objects with `name` and `address`) privately. Use a dedicated DNS machine; inspect existing systemd-resolved listeners and dnsmasq configuration first. API DNS must already work for `canopy`, regardless of its owner.

After `canopy`, securely retrieve `/etc/kubernetes/admin.conf` from the first control plane, protect it with mode 0600 and verify API identity. Set its absolute controller path as `reforge_kubeconfig`. This is a bootstrap administrative credential, not a workload identity. For expansion, retain the original control plane in the inventory and rerun `roots`/`canopy` with the full inventory; existing joins are skipped, tokens last 15 minutes and are revoked after use. Do not exclude the source control plane with `--limit`.

Cilium uses VXLAN as a portable starting point. Permit the selected release's node-to-node ports and keep announcing interfaces on the VIP's actual L2. Native routing and WireGuard encryption need separate routing/kernel qualification. Pool selection is scoped to the shared Gateway. Helm atomic rollback does not undo CRDs or persistent data. Never downgrade CRDs as an automatic recovery step.

For optional LocalPV LVM, enable `reforge_lvm_enabled`, select its chart version, set `reforge_lvm_volume_group` and list `reforge_lvm_nodes` from the private inventory. The role verifies that the volume group already exists on each selected node and installs the CSI driver plus a topology-restricted Retain class. It never runs `pvcreate`, `vgcreate` or disk cleanup. Treat volume-group creation/migration as a separately reviewed storage operation; LocalPV remains node-local.

The encryption role refuses a different existing key. Rotation requires retaining old/new keys, restarting or reloading all API servers, rewriting Secrets, validating decryption/recovery and only then retiring the old key. Bootstrap reruns do not perform rotation.

## Identity, services and ownership

Use GitHub organization membership as the human directory, with separate OAuth applications for Access, Argo Dex and Backstage. Dex callback: `https://argocd.<internal-domain>/api/dex/callback`; Backstage callback: `https://<backstage-host>/api/auth/github/handler/frame`. Use the callback Cloudflare provides for Access. Local Argo recovery stays enabled until SSO and recovery are independently tested.

Argo and Grafana remain private ClusterIP services; use authenticated port-forwards or separately reviewed private routes. Argo serves HTTPS. The supplied HTTPRoute is Backstage only. The root repository must be controlled by platform administrators: its project can define child Applications/AppProjects in `argocd`. Ordinary applications use `reforge-apps` with explicit destinations and no cluster-scoped grants. For private HTTPS Git repositories, populate a private directory with files `type`, `url`, `username`, `password`, then use `secret-file.sh plan|apply CONTEXT argocd REPOSITORY_SECRET DIRECTORY argocd-repository`. Do not include a trailing newline in credential files unless intended.

Build Backstage separately and supply an immutable image with GitHub authentication, GitHub organization catalog import, PostgreSQL, health endpoints and a reviewed permission policy. `permission.enabled` enables the framework; the image must implement the actual authorization policy. The launcher assumes `node packages/backend`, UID 1000 and port 7007. Test those contracts. Provision the database role/per-plugin databases on a backed-up PostgreSQL service first. Set `reforge_backstage_database_cidr` to the real DB range and supply its CA file for verified TLS. For ECR set `reforge_backstage_image_pull_secret: ecr-pull` after refreshing that Secret.

Backstage matches GitHub IDs to imported catalog entities, with no guest bypass. Its token needs only the selected organization's catalog/repository read access. A later GitHub App migration is a separate credential change. Baseline namespaces allow DNS only; the application policy adds Gateway ingress, selected DB traffic and GitHub HTTPS. Verify the chosen Cilium version's Gateway `ingress` identity, FQDN DNS policy and host probes with negative tests.

Create a remotely managed Cloudflare tunnel, GitHub identity provider and restricted Access application first. Test rejected-user behavior, then set `reforge_access_policy_verified: true`. Publish **Backstage only** initially. Use origin `https://<gateway-ip>:443`, with `originServerName` and `httpHostHeader` set to the Backstage hostname, TLS verification enabled, and that hostname in `reforge_tls_names`. Staging ACME certificates are untrusted; finish production issuance before ordinary tunnel use. Connector anti-affinity requires two workers. No router, hypervisor, BMC, SSH or API route is published.

Ansible initially owns these resources. For GitOps handoff, commit reviewed values/manifests, compare live state, sync without destructive pruning first, and stop invoking the corresponding Ansible role. Record one owner per chart, route, Secret and policy. ESO installation does not choose a secret backend. Loki/Alloy installation requires private values with explicit storage/retention decisions; their names alone do not define a logging service.

The [Loki](../automation/values/loki.example.yml) and [Alloy](../automation/values/alloy.example.yml) examples provide a small single-binary/LocalPV lab and one API-based collector. Copy/adapt them privately and set the absolute `reforge_loki_values_file`/`reforge_alloy_values_file` paths plus chart versions before enabling logging. Loki is unauthenticated and cluster-internal in this lab recipe; do not expose it publicly. Choose authenticated object storage and retention/tenant policy separately for a durable shared service.

## AWS integration

Cloud helpers require a named AWS profile, and Kubernetes changes require an explicit context. On-prem Argo pods need a **renewable runtime identity** capable of assuming target deployer roles. Workstation SSO does not authenticate pods; an IRSA annotation alone does not establish on-prem federation. Configure a reviewed credential-process/Roles Anywhere or equivalent mechanism in each Argo component that needs remote cluster authentication. Verify `argocd-k8s-auth` exists in the selected image.

The [AWS policies](../automation/aws/deployer-trust.example.json) contain only dummy account values and project naming. Adapt privately: both the runtime policy and target trust must permit `sts:AssumeRole`. Target deployment roles need cluster description access and namespace-scoped EKS authorization.

```bash
bash scripts/eks-access.sh plan target-dev us-east-1 forest-dev \
  arn:aws:iam::123456789012:role/argocd-forest-dev-deployer apps
bash scripts/eks-register.sh plan core operator us-east-1 forest-dev \
  arn:aws:iam::123456789012:role/argocd-forest-dev-deployer apps
bash scripts/ecr-refresh.sh plan core operator us-east-1 \
  123456789012.dkr.ecr.us-east-1.amazonaws.com backstage ecr-pull
```

Use `apply` only with configured identities/targets. EKS access mode must already support access entries. The helper grants namespace-scoped `AmazonEKSEditPolicy`, including workload Secrets in that namespace. Audit other grants; it does not remove broader permissions. Reassociating that policy replaces its namespace scope. Registration also limits Argo namespaces and disables cluster resources. Test DNS, VPN routing, TLS, STS and Kubernetes authorization from the runtime pod separately. Production targets are not activated automatically.

ECR tokens expire after 12 hours. The helper passes credentials through private temporary files and creates a namespace-local pull Secret. Adapt the [refresh service](../automation/services/ecr-refresh.service.example) and timer to a renewable AWS profile and explicit context; monitor failures. Set `imagePullSecrets` on consuming workloads. ECR read permission does not grant application AWS access. Examples target the commercial `aws` partition; adapt endpoints/ARNs for other partitions deliberately.

## Hypervisor, drivers and kernels

`proxmox-vm.sh --help` describes a checked cloud-image import with a public SSH key and explicit storage/network inputs. It creates a new stopped guest; review CPU baseline, cloud-init user/sudo settings, disk size, guest agent and network before starting. It refuses existing VMIDs and leaves partial imports for inspection rather than deleting disks.

`gpu-diagnose.sh BDF [KERNEL]` collects selected-device binding, IOMMU peers, modules, service results and profiles. `kernel-gate.sh KERNEL passthrough|vgpu|compute` checks boot files, headers and module vermagic without changing boot selection. Missing optional modules can be expected. A successful artifact check is not runtime compatibility proof. Keep the first installer/DKMS error and a known-working kernel.

`gpu-driver.sh INSTALLER SHA256 NEW_PRIVATE_DIRECTORY` verifies and extracts a trusted, entitled installer only. Extraction executes vendor installer code. Install the qualified manager through its reviewed procedure and test stock compilation before applying an error-matched patch. Record final diff/checksum and signing. No fabricated compatibility patches, license bypass, wildcard purge, ACS override or automatic reboot is supplied.

`vgpu-attach.sh plan|apply VMID BDF NATIVE_PROFILE_ID` requires profile capacity, a stopped VM and unused `hostpci0`. Keep virtual VGA, install the matching guest driver/license and test CUDA, repeated restarts, host reboot, thermals and PCIe errors. Read the [P4 runbook](r710-p4-vgpu-runbook.md) before choosing a branch; inspect `vgpud` result and manager/profile evidence together.

## DRAC5 viewer

The [viewer bundle](../automation/drac5/compose.yml) implements the chat's confirmed manual fresh-JNLP architecture. It is a new implementation, not the missing historical ZIP or a proven automatic-login fetcher. Supply these private files:

```text
automation/drac5/.env                         # from environment.example
automation/drac5/private/jdk8-i386.tar.gz      # 32-bit x86 JDK8
automation/drac5/private/vnc-password         # separate from BMC password
automation/drac5/private/runtime/vkvm.jnlp    # fresh session
automation/drac5/private/runtime/avctDRAC5Viewer.jar
automation/drac5/private/runtime/avctKVMIOLinux.jar
```

Choose a reviewed Debian i386 base digest and record the JDK archive SHA-256 in `.env`. Obtain the JARs from the authenticated controller. Use private directory/file permissions; on Linux the container UID 1000 must be able to read mounted assets. The Docker build context excludes all private files except the JDK archive. No controller JAR/session enters the image.

Run `bash scripts/drac5.sh build`, then `bash scripts/drac5.sh vnc`. Docker must support linux/386 emulation. The viewer checks ELF32 JNI, disables XML external entities and keeps JNLP tokens out of process arguments. VNC binds to loopback and requires a password. Enable **Tools → Session Options → General → Pass all keystrokes to target**. Preferences persist in a named volume. Stop with `bash scripts/drac5.sh down` and remove expired private session files; the state volume is retained.

OOB DNS and ports 5900/5901 must work from the container. No legacy TLS relaxation is enabled. Scope any unavoidable exception to this runtime after inspecting the handshake failure. Automatic browser login and noVNC remain optional future work; the chat supplied no demonstrated fetcher. See the [DRAC5 runbook](drac5-apple-silicon-runbook.md).

## Recovery, validation and publication

Backups contain private keys and the Secret encryption key. Protect destination storage with encryption and permissions. The collector locks concurrent runs, validates the etcd snapshot, archives `/etc/kubernetes`, writes checksums, optionally copies over verified SSH and marks completion after successful steps. It never prunes recovery material. Provision remote directories/ownership first. Verify remote checksums and an isolated restore; rsync success is not a restore test. Application data and external configuration need separate backups.

Run `python -m unittest discover -s tests -v` for offline contracts. See [package validation](package-validation.md) for the actual checks and limits. No infrastructure deployment was used to validate this iteration.

`package-release.sh NEW_OUTPUT.tar.gz` creates an allowlisted generic archive. It excludes the entire reference tree, local inventory/runtime files, IDE state, virtualenvs and build output. Historical evidence remains available locally; historical source links require that local copy. Review the archive before publishing. `.gitignore` is a separate backstop and does not untrack already committed files.

Primary API references: [kubeadm v1beta4](https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta4/), [Cilium Gateway API](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/), [Argo declarative clusters](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/), [Backstage GitHub auth](https://backstage.io/docs/auth/github/provider/), [Cloudflare Kubernetes tunnel](https://developers.cloudflare.com/tunnel/guides/kubernetes/). Check behavior against your selected releases.
