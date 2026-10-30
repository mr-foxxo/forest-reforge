# Release notes

[English (default)](RELEASE.md) | [Português (Brasil)](RELEASE.pt-BR.md) | [Documentation index](docs/README.md)

## Bilingual documentation

English remains the default. Releases also include `README.pt-BR.md`, `CONTRIBUTING.pt-BR.md`, `RELEASE.pt-BR.md` and adapted Brazilian Portuguese guides under `docs/pt-BR/`. The [English](docs/README.md) and [Portuguese](docs/pt-BR/README.md) indexes link every paired document. Executable examples, automation and evidence assets remain shared.

## 2026-10-30 · Operator inventory reconciliation

The English and Brazilian Portuguese guides now include the current generic infrastructure inventory and all thirteen Kubernetes VM allocations. The operator inventory identifies the T310/T410 infrastructure-only platforms and PowerEdge 2950 NAS, confirms guest placement, and records 14 control-plane plus 64 worker vCPUs with a V100 note on core-wk05.

The [inventory guide](docs/den-inventory.md) and [Portuguese counterpart](docs/pt-BR/den-inventory.md) retain the source RAM values without inventing a unit. The shared JSON and Den-sized example carry descriptive allocation metadata separately from the earlier measured Node capacity/allocatable values. Original aliases and addresses remain private. Paired indexes, platform/experiment records, modules and automation guidance are updated together.

## 2026-10-28 · Platform evidence and automation

Forest Reforge combines thirteen infrastructure modules with phased configuration, operational helpers and a documented Den platform. Public examples follow the project's naming conventions and use generic addresses and private configuration inputs.

### Included

- Ansible phases for node preparation, kubeadm, Cilium, Gateway API, DNS/TLS, storage, identity, GitOps, Backstage, monitoring and recovery.
- AWS EKS/ECR helpers and IAM examples with explicit account, namespace and credential inputs.
- Proxmox guest provisioning, GPU/kernel diagnostics, driver preparation, vGPU attachment and legacy DRAC5 console tooling.
- A generic hardware/NAS/resource snapshot, a five-control-plane/eight-worker inventory example and a read-only Node resource checker.
- Observed VM placement, standalone-host quorum analysis, a validation/experiment ledger and two unchanged public Grafana screenshots with an integrity manifest.
- Architecture, compatibility, troubleshooting, acceptance and contribution guides, plus automated tests and release packaging.

### Verification record

| Area | Result |
|---|---|
| Repository behavior | Automated tests cover helper behavior, resource/placement accounting, public image integrity, configuration, privacy and packaging; see the validation report for results |
| Ansible configuration | All 15 playbooks passed syntax checks; 16 templates rendered and parsed in both optional-feature modes |
| Shell helpers | All 17 shell helpers and the DRAC5 entrypoint passed syntax checks |
| Den infrastructure evidence | Seven baseline plus ten follow-up views reviewed; two clean Grafana originals versioned in assets with SHA-256 checksums |
| Placement and runtime | Three/two control-plane and four/four worker host split observed; selected-node and Argo workload resource panels recorded |
| Worker resource snapshot | 64 CPU and 124.1 GiB allocatable memory recorded for the eight-worker scope |
| Inventory membership | Two Kubernetes guest hosts and two infrastructure-only hypervisors represented separately |
| Release archive | Public deliverables and license included; private references, inventories, credentials and runtime state excluded |

The [validation report](docs/package-validation.md) provides the check details and reproduction commands. The [Den platform record](docs/den-case-study.md) documents the operational observations and their scope. The [acceptance guide](docs/acceptance.md) defines functional checks for deployments and changes.

### Configuration and ownership

Use the [automation guide](docs/automation.md) to select an inventory, fill in the private site contract and run phases in dependency order. Maintain one reconciling owner per resource when transferring bootstrap configuration to GitOps. Supply the selected application images, toolchain/driver packages and runtime credentials through the documented private inputs.

Public files use role-based identifiers, example domains and documentation addresses. Two individually reviewed dashboard originals are published through the [asset manifest](assets/evidence.json); private screenshot views, alias mappings, source inventories and vault material stay in ignored local/reference paths. The [experiment ledger](docs/den-validations-experiments.md) and [source map](docs/automation-source-map.md) record how operational evidence and implementation references inform the generic configuration.

### Build a release archive

From the repository root, choose a new archive filename:

```bash
mkdir -p dist
bash scripts/package-release.sh dist/forest-reforge-2026-10-28.tar.gz
shasum -a 256 dist/forest-reforge-2026-10-28.tar.gz > dist/forest-reforge-2026-10-28.tar.gz.sha256
tar -tzf dist/forest-reforge-2026-10-28.tar.gz
```

The packager includes `README.md`, `CONTRIBUTING.md`, `RELEASE.md`, their `.pt-BR.md` alternatives, `LICENSE`, guides, examples, assets, modules, scripts, automation and tests. It excludes raw references, private runtime files, local configuration, IDE state, virtual environments and bytecode. It refuses to overwrite an existing archive. Review the member list and checksum before publishing the release.

### License

Forest Reforge is distributed under the [GNU General Public License v3.0](LICENSE). Preserve the license and applicable third-party notices in distributions.
