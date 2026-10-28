# Package validation

Evidence update: 2026-10-28. Repository checks are offline; the separately reviewed screenshot observations are not deployment acceptance.

## Checks performed

- Twenty-three offline tests passed: helper behavior, checked installer rejection, mocked AWS operations, encryption/identity boundaries, YAML/templates, shell syntax and release exclusions; plus Node quantity parsing, worker/control-plane accounting, snapshot drift, incomplete-input rejection, privacy, explicit-context collection and inventory membership.
- All 15 Ansible playbooks passed `ansible-playbook --syntax-check` using the pinned controller and collections. The two contract roles were also exercised locally with synthetic inputs to verify refusal of an unreviewed inventory and mismatched Kubernetes context.
- The main playbook also passed syntax checking with the new 5-control-plane/8-worker example inventory; tests verified that the infrastructure-only hypervisors and NAS are outside `canopy`.
- All 16 Ansible templates rendered with synthetic documentation identities in both optional-feature modes; rendered YAML parsed successfully. Both ACME modes, GitHub Dex, DB TLS, image-pull Secret and kube-vip bootstrap/steady state were covered.
- All 17 shell helpers and the DRAC5 entrypoint passed `bash -n`.
- The DRAC5 Java launcher compiled with Java 8 target compatibility. Compose configuration validation passed with synthetic build inputs; no image was pulled or built.
- Local Markdown links and code-fence balance checked across the 35 current guide/module/example files.
- AWS policy examples parsed as JSON. New automation was reviewed for original environment identifiers and common credential patterns; only documentation IPs, example domains, dummy account values and empty secret inputs are used.
- An allowlisted generic tar archive was created and its member list inspected. Raw references, historical chats, private runtime/configuration, IDE state, virtualenvs and bytecode were absent. A test with private sentinel files independently verified these exclusions.
- Seven original evidence images were visually reviewed, with source hashes and private aliases recorded under ignored `local/den-evidence/`. The generic derivative records displayed CPU/RAM/kernel/manager fields, NAS pool state, 13 Ready kubelet entries and worker-scoped totals. Capture date and per-VM placement remain unknown. The images do not validate workload/recovery acceptance or the new bootstrap implementation.

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

The new checker was exercised with synthetic Node API responses and a mocked kubectl call, not against the real Den. Its aggregate/profile checks do not refresh dashboard usage/requests/limits, inspect Pod specs, establish VM placement, or certify service/failover readiness. Snapshot-derived per-node CPU/RAM allocations were deliberately not invented.

The JDK, proprietary controller JARs, driver packages, Backstage application image, runtime AWS credential mechanism and real private contract are operator inputs. Exact rack measurements, final GPU patches and automatic DRAC5 login remain unverified. Pattern scans are not exhaustive secret detection. Original source files were not modified; they remain local evidence outside the public package.
