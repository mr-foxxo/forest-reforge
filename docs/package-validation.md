# Package validation

[English (default)](package-validation.md) | [Português (Brasil)](pt-BR/package-validation.md) | [Documentation index](README.md)

Evidence update: 2026-10-28. Repository checks are offline; the separately reviewed screenshot observations are not deployment acceptance.

## Checks performed

- Twenty-five offline tests cover helper behavior, mocked AWS operations, encryption/identity boundaries, YAML/templates, shell syntax and release exclusions; Node quantity parsing, role/placement accounting and drift; plus public-image hashes, PNG structure/metadata and manifest coverage.
- All 15 Ansible playbooks passed `ansible-playbook --syntax-check` using the pinned controller and collections. The two contract roles were also exercised locally with synthetic inputs to verify refusal of an unreviewed inventory and mismatched Kubernetes context.
- The main playbook also passed syntax checking with the new 5-control-plane/8-worker example inventory; tests verified that the infrastructure-only hypervisors and NAS are outside `canopy`.
- All 16 Ansible templates rendered with synthetic documentation identities in both optional-feature modes; rendered YAML parsed successfully. Both ACME modes, GitHub Dex, DB TLS, image-pull Secret and kube-vip bootstrap/steady state were covered.
- All 17 shell helpers and the DRAC5 entrypoint passed `bash -n`.
- The DRAC5 Java launcher compiled with Java 8 target compatibility. Compose configuration validation passed with synthetic build inputs; no image was pulled or built.
- Local Markdown links, image destinations and code-fence balance are checked across the current guides, modules, examples and asset documentation.
- AWS policy examples parsed as JSON. New automation was reviewed for original environment identifiers and common credential patterns; only documentation IPs, example domains, dummy account values and empty secret inputs are used.
- An allowlisted generic tar archive was created and its member list inspected. Raw references, historical chats, private runtime/configuration, IDE state, virtualenvs and bytecode were absent. A test with private sentinel files independently verified these exclusions.
- Seven baseline and ten follow-up source images were visually reviewed, with hashes/private aliases recorded under ignored `local/den-evidence/`. Two clean Grafana originals are versioned unchanged in assets with SHA-256 values in the public manifest. The follow-up views establish the three/two control-plane and four/four worker host split, standalone Proxmox mode, selected-node sizing, resource metrics and visible Argo running-pod counts. Private account/host/address views remain outside public assets. See the [experiment ledger](den-validations-experiments.md) for the scope of each result.

## Reproduce

Set up the controller as described in [automation.md](automation.md), then run from the repository root:

```bash
. .venv/bin/activate
python -m unittest discover -s tests -v
```

The mocked AWS checks need jq; they skip explicitly if it is unavailable. They use shell stubs and synthetic responses, not AWS credentials. For syntax checks, change to `automation/ansible`, ensure the pinned collections are installed, and run:

```bash
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory.example.yml -e @site.example.yml "$playbook" --syntax-check || exit
done
```

The archive helper requires a new output path and refuses to overwrite an existing file. Historical source links intentionally need the local reference tree, which is excluded from the generic archive.

## Limits

No live host, GPU, BMC, router, Kubernetes cluster or AWS account was accessed or modified. No target package/chart tuple, CNI datapath, identity login, persistent-volume restore, driver build, JNI console session or cloud authorization has been certified. Ansible check mode cannot model all missing prerequisites. Chart values and CRDs must be checked against selected release versions before deployment.

The Node checker was exercised with synthetic API responses and a mocked kubectl call. Its aggregate/profile checks do not refresh dashboard queries or establish VM placement: placement is recorded from the separate Proxmox views. Public tests check consistency of that mapping with the generic inventory and check integrity/metadata of the reviewed images. Only the selected core-cp01 view supplies per-node sizing; allocations for other nodes are not inferred.

The JDK, proprietary controller JARs, driver packages, Backstage application image, runtime AWS credential mechanism and real private contract are operator inputs. Exact rack measurements, final GPU patches and automatic DRAC5 login remain unverified. Pattern scans are not exhaustive secret detection. Original source files were not modified; they remain local evidence outside the public package.
