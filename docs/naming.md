# Project and resource naming

[English (default)](naming.md) | [Português (Brasil)](pt-BR/naming.md) | [Documentation index](README.md)

**Forest Reforge** describes reusing capable hardware through careful engineering. It connects the Forest identity with the practical act of rebuilding. The repository slug is `forest-reforge`; no uniqueness/trademark claim is made.

Use role-based names in portable examples and friendly aliases in local descriptions.

| Kind | Pattern | Example |
|---|---|---|
| Physical site | short site label | den |
| Router / DNS | role + two digits | gw01, dns01 |
| Hypervisor | hv + two digits | hv01, hv02 |
| NAS | nas + two digits | nas01 |
| OOB | mgmt + host | mgmt.hv01.den.int.example.net |
| K8s node | cluster-role-number | core-cp01, core-wk01 |
| App hostname | app.site.int.domain | backstage.den.int.example.net |
| API hostname | api.k8s.site.int.domain | api.k8s.den.int.example.net |
| Cloud cluster | unit-environment | forest-dev, foxbyte-dev |
| AWS role | purpose-unit-environment | argocd-forest-dev-deployer |
| Resource tags | Project, Owner, Environment, Site, ManagedBy | ForestReforge, platform, dev, den, argo |
| GitOps application | site-purpose | den-platform |

Keep the OS short hostname aligned with the inventory. Provide the FQDN through DNS and hosts configuration. Decide node names before kubeadm; renaming a joined node is a lifecycle operation, not merely editing `/etc/hostname`.

In the [observed-platform example](../examples/observed-platform.json), hv01/hv02 host Kubernetes guests, hv03/hv04 are infrastructure-only hypervisors, and nas01 is independent storage infrastructure. These aliases describe scope, not additional Kubernetes nodes. Private alias-to-machine provenance remains under ignored `local/den-evidence/`; raw screenshot hostnames do not enter the public inventory. Published names are not an instruction to rename existing equipment.

A wildcard for `*.den.int.example.net` covers `grafana.den.int.example.net`, but neither `mgmt.hv01.den.int.example.net` nor `api.k8s.den.int.example.net`. Issue separate certificates/SANs for those names.
