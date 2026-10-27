# Package validation

Automation iteration: 2026-10-27. These are offline checks, not deployment acceptance.

## Checks performed

- Fifteen offline tests passed: helper help/argument handling, path preservation, checked installer rejection, ECR region validation, mocked EKS registration/ECR renewal, encryption-key preservation, identity boundaries, YAML parsing, template rendering, shell syntax and release exclusions.
- All 15 Ansible playbooks passed `ansible-playbook --syntax-check` using the pinned controller and collections. The two contract roles were also exercised locally with synthetic inputs to verify refusal of an unreviewed inventory and mismatched Kubernetes context.
- All 16 Ansible templates rendered with synthetic documentation identities in both optional-feature modes; rendered YAML parsed successfully. Both ACME modes, GitHub Dex, DB TLS, image-pull Secret and kube-vip bootstrap/steady state were covered.
- All 17 shell helpers and the DRAC5 entrypoint passed `bash -n`.
- The DRAC5 Java launcher compiled with Java 8 target compatibility. Compose configuration validation passed with synthetic build inputs; no image was pulled or built.
- Local Markdown links and code-fence balance checked across the 35 current guide/module/example files.
- AWS policy examples parsed as JSON. New automation was reviewed for original environment identifiers and common credential patterns; only documentation IPs, example domains, dummy account values and empty secret inputs are used.
- An allowlisted generic tar archive was created and its member list inspected. Raw references, historical chats, private runtime/configuration, IDE state, virtualenvs and bytecode were absent. A test with private sentinel files independently verified these exclusions.

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

The JDK, proprietary controller JARs, driver packages, Backstage application image, runtime AWS credential mechanism and real private contract are operator inputs. Exact rack measurements, final GPU patches and automatic DRAC5 login remain unverified. Pattern scans are not exhaustive secret detection. Original source files were not modified; they remain local evidence outside the public package.
