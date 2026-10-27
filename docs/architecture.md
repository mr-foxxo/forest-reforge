# Architecture and evidence

## Boundaries

Forest Reforge separates the physical facility, management plane, workload plane and cloud control plane. This makes it possible to replace a GPU or rebuild Kubernetes without also losing DNS, router administration and recovery access.

| Layer | Owns | Must not become |
|---|---|---|
| Physical facility | Rack, power distribution, cooling, patching | An undocumented dependency |
| OpenWrt | Routed zones, ingress filtering, VPN admission | A broad bridge between trust zones |
| Independent DNS | Internal authoritative records and selected recursion | Dependent on the cluster it must bootstrap |
| Proxmox | VM lifecycle, devices, host storage | An application package playground |
| Kubernetes | Stateless services and explicitly selected state | The only copy of backups or credentials |
| Cilium + Gateway API | Pod networking, policies, application routing | Public infrastructure management |
| Cloudflare | Published application access and edge transport | A replacement for application authorization |
| GitHub | Human membership, source and delivery workflow | An implicit grant of cluster-admin |
| AWS | Account boundaries, regional services, EKS | A flat extension of the den LAN |

## Evidence levels

- **Source-reported:** supplied operational documentation or visible chat says this was implemented or observed; not verified against live equipment here.
- **Proposed:** a generic design or procedure synthesized for readers.
- **Experimental:** requires qualification, may lack vendor support.
- **Unknown:** records do not settle it.

The source files contain both successful-execution statements and outstanding acceptance lists. A playbook described as implemented is not proof that every failover, restore, security boundary or workload has passed.

The repository includes sanitized full exports of the two added vGPU and DRAC5 chats. Other available history is summaries/selected messages; additional personal-context retrieval was unavailable. Every supplied file is retained in sanitized form for traceability.

## Canonical example topology

For a coherent **new build**, use Kubernetes nodes on the Servers L2 subnet, matching the operational bootstrap/status documents. This permits the example Cilium VIP pool on that same segment. It is not an instruction to renumber an existing working site.

The older VM-subnet layout is valid only with its own routed/L2 design. If workers exist only on the VM segment, they cannot answer ARP directly on a separate Servers segment. Move the VIP to their L2 domain or deliberately design routed advertisement; do not compensate by bridging security zones.

## Failure domains

Three control-plane VMs on one physical host protect against some VM failures, not host failure. Three voters on two hosts cannot survive either host loss symmetrically. Keep the initial deployment honest about this. Add an independent third physical failure domain before claiming host-resilient quorum.

Two cloudflared replicas on one host have the same limitation. Two PSUs on one PDU do not make two power paths. LocalPV is not distributed storage. A second DNS process on the same failing disk is not independent DNS recovery.

## Delivery ownership

Ansible bootstraps the substrate and agreed bootstrap secrets. Argo owns runtime application desired state. AWS/Cloudflare account setup is a separate control plane. Assign exactly one reconciling owner to each Kubernetes object, including Namespace, Secret, Gateway and Application objects.

## Public example conventions

Domains become `example.net` / `example.org`; GitHub organizations become `example-org`; AWS account IDs become `111122223333` and `444455556666` where needed. RFC1918 subnets remain illustrative, not secret. No working account identifiers, credentials, device serials or WAN addresses are needed to reproduce the design.
