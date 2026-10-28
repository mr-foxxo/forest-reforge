# Contributing to Forest Reforge

Contributions make reused hardware easier to configure, operate and recover. Describe the concrete problem, the resulting behavior, the versions involved, how you checked the change and how to reverse it.

## Follow the project conventions

Read the relevant [module](README.md#the-modules), [naming conventions](docs/naming.md), [decision register](docs/decisions.md) and [automation guide](docs/automation.md) before changing a configuration contract. Keep changes focused and update the associated example and guide together.

Write documentation in English. Use role-based hostnames, example domains, documentation addresses and dummy account IDs in public files. Keep private inventory, credentials, raw evidence and runtime artifacts in the ignored `local/` or `reference/` trees. Keep secrets out of command output, diffs, screenshots and pull-request descriptions.

For screenshots, review both visible content and embedded metadata before copying publishable originals into `assets`. Register public evidence images and their SHA-256 values in [assets/evidence.json](assets/evidence.json), and link them from the relevant record with the dashboard scope/time range. Keep private originals and alias mappings separately. Follow [the current evidence examples](assets/README.md); preserve measured pixels and identify any future redacted derivative explicitly.

Preserve the distinction between Kubernetes guest nodes, Kubernetes-hosting hypervisors and infrastructure-only hosts. Resource records must identify whether their scope is a physical host, control planes, workers or the whole cluster. Record evidence review dates separately from capture times, and retain the original measurement units.

## Record useful evidence

| Change | Include |
|---|---|
| Hardware or GPU | Exact hardware/software tuple, exposure mode, application kernels, thermal/power observations, restart behavior and rollback; use the [stack record](examples/validated-stack.md) |
| Networking or identity | Positive and rejected paths, IPv4/IPv6 scope, authorization boundary and recovery access |
| Storage or recovery | Data ownership, persistence expectations, backup location and restore results |
| Kubernetes resources | Role counts, versions, capacity versus allocatable resources, metrics scope and private placement records where relevant |
| Cloud integration | Account/namespace scope, runtime identity mechanism and permitted/denied operations, with live identifiers removed |
| Automation | Required inputs, configuration ownership, idempotency, failure handling and post-change checks |

Keep vendor support information distinct from results obtained with local patches. Record the command, expected outcome and observed result for functional tests. Preserve source attribution and checksums for external inputs.

## Validate your change

Prepare the controller environment using the [setup guide](docs/automation.md). With that environment active, run the relevant checks below.

For Python helpers, templates, configuration contracts or packaging:

```bash
python -m unittest discover -s tests -v
```

The AWS helper tests use mocked commands; jq enables those checks. For shell changes, also check the affected script with `bash -n path/to/script.sh`.

For Ansible changes, run from `automation/ansible` with the pinned collections installed:

```bash
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory.example.yml -e @site.example.yml "$playbook" --syntax-check || exit
done
ansible-playbook -i inventory.observed.example.yml -e @site.example.yml playbooks/main.yml --syntax-check
```

For documentation, check relative links, code fences, paths and consistency with the shipped examples. For operational changes, use the relevant [acceptance checks](docs/acceptance.md) and record the target environment and results. For release changes, build a fresh archive using [RELEASE.md](RELEASE.md), verify that `LICENSE` is included, and inspect exclusions and checksums.

## Submit a reviewable change

Explain the problem and final behavior in the pull request. Include the applicable checks and their results, exact versions, configuration ownership changes and rollback steps. Update [RELEASE.md](RELEASE.md) when the change affects release contents or user-facing behavior. Keep private logs and credentials outside the public submission.

## License and external material

Contributions follow the repository's [GNU General Public License v3.0](LICENSE). Preserve authorship and applicable third-party notices. Reference operator-supplied drivers, firmware, controller JARs and credential material through the documented private-input workflow; contribute only files you have permission to distribute.
