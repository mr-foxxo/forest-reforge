# Release notes

## 2026-10-28 · Platform evidence and automation

Forest Reforge combines thirteen infrastructure modules with phased configuration, operational helpers and a documented Den platform. Public examples follow the project's naming conventions and use generic addresses and private configuration inputs.

### Included

- Ansible phases for node preparation, kubeadm, Cilium, Gateway API, DNS/TLS, storage, identity, GitOps, Backstage, monitoring and recovery.
- AWS EKS/ECR helpers and IAM examples with explicit account, namespace and credential inputs.
- Proxmox guest provisioning, GPU/kernel diagnostics, driver preparation, vGPU attachment and legacy DRAC5 console tooling.
- A generic hardware/NAS/resource snapshot, a five-control-plane/eight-worker inventory example and a read-only Node resource checker.
- Architecture, compatibility, troubleshooting, acceptance and contribution guides, plus automated tests and release packaging.

### Verification record

| Area | Result |
|---|---|
| Repository behavior | 23 automated tests passed, covering helper behavior, resource accounting, configuration, privacy and packaging |
| Ansible configuration | All 15 playbooks passed syntax checks; 16 templates rendered and parsed in both optional-feature modes |
| Shell helpers | All 17 shell helpers and the DRAC5 entrypoint passed syntax checks |
| Den infrastructure evidence | Seven images reviewed: four Proxmox hypervisors, a TrueNAS system and 13 Ready Kubernetes nodes at kubelet v1.36.4 |
| Worker resource snapshot | 64 CPU and 124.1 GiB allocatable memory recorded for the eight-worker scope |
| Inventory membership | Two Kubernetes guest hosts and two infrastructure-only hypervisors represented separately |
| Release archive | Public deliverables and license included; private references, inventories, credentials and runtime state excluded |

The [validation report](docs/package-validation.md) provides the check details and reproduction commands. The [Den platform record](docs/den-case-study.md) documents the operational observations and their scope. The [acceptance guide](docs/acceptance.md) defines functional checks for deployments and changes.

### Configuration and ownership

Use the [automation guide](docs/automation.md) to select an inventory, fill in the private site contract and run phases in dependency order. Maintain one reconciling owner per resource when transferring bootstrap configuration to GitOps. Supply the selected application images, toolchain/driver packages and runtime credentials through the documented private inputs.

Public files use role-based identifiers, example domains and documentation addresses. Original screenshots, alias mappings, source inventories and vault material stay in ignored local/reference paths. The [source map](docs/automation-source-map.md) records how the on-prem implementation and chats inform the generic configuration.

### Build a release archive

From the repository root, choose a new archive filename:

```bash
mkdir -p dist
bash scripts/package-release.sh dist/forest-reforge-2026-10-28.tar.gz
shasum -a 256 dist/forest-reforge-2026-10-28.tar.gz > dist/forest-reforge-2026-10-28.tar.gz.sha256
tar -tzf dist/forest-reforge-2026-10-28.tar.gz
```

The packager includes `README.md`, `CONTRIBUTING.md`, `RELEASE.md`, `LICENSE`, guides, examples, assets, modules, scripts, automation and tests. It excludes raw references, private runtime files, local configuration, IDE state, virtual environments and bytecode. It refuses to overwrite an existing archive. Review the member list and checksum before publishing the release.

### License

Forest Reforge is distributed under the [GNU General Public License v3.0](LICENSE). Preserve the license and applicable third-party notices in distributions.
