# Release notes — automation iteration

Updated 2026-10-28. Suggested repo: `forest-reforge`. Nothing has been published to GitHub.

## Included

Thirteen modular guides; phased Ansible roles and private contract examples; Kubernetes/Cilium/Gateway/TLS/storage configuration; GitHub/Argo/Backstage/tunnel integrations; monitoring and optional logging/secrets controllers; EKS/ECR helpers and IAM examples; Proxmox/GPU/kernel/recovery helpers; isolated DRAC5 viewer; offline tests and an allowlisted release packager. The source map records coverage of all 26 notes, the supplied roles and both chats.

The evidence update adds a generic hardware/NAS/resource snapshot, a 5-control-plane/8-worker example inventory and a read-only Node resource checker. Seven supplied screenshots show 13 Ready nodes at kubelet v1.36.4 and worker-scoped resource totals. Four hypervisors are recorded, with two explicitly outside Kubernetes hosting. Raw images, private aliases and source hashes remain excluded from publication; displayed operational state is distinguished from unperformed functional acceptance.

## Boundaries

The on-prem implementation was supplied locally for this iteration and used as a reference. Its original inventory, vault, artifacts and deployment values are excluded from version control and the generic release. New configurations use project naming and operator-supplied values. The release helper excludes the entire reference/history tree; source links in the guides require the local copy.

No Backstage application source, proprietary driver/JDK/controller binaries or final applied GPU patch is distributed. The historical DRAC5 ZIP was unavailable; the new viewer reconstructs its confirmed architecture without claiming automatic login. No hardware/cloud deployment test was performed. Exact target versions, runtime AWS identity, database durability, physical measurements and GPU qualification remain operator inputs.

## Before public publication

- Choose a documentation/code license and add the corresponding license text. This draft does not choose legal terms on the owner's behalf.
- Review branding/author attribution and any retained private topology examples.
- Add redacted real build photos/measurements if desired; do not fabricate them.
- Replace proposed stack fields with independently tested records when available.
- Review archived source warnings: old commands and unresolved contradictions remain for provenance, not execution.

## Validation report

See [package-validation.md](docs/package-validation.md) for actual checks. Use `bash scripts/package-release.sh /absolute/path/forest-reforge.tar.gz` to create a generic archive after review. No remote deployment or hosted service was changed.
