# Site contract template

**Proposed example, not the originating site's asserted live inventory.** Replace all values deliberately before using snippets. `example.net` cannot be used to obtain your own ACME certificate.

```yaml
project: forest-reforge
site: den
domain: example.net
internal_domain: den.int.example.net
hosts:
  router: gw01
  dns: dns01
  hypervisors: [hv01, hv02]
networks:
  clients: 172.16.1.0/24
  oob: 172.16.2.0/24
  servers: 172.16.3.0/24
  vms: 172.16.4.0/24
  infra: 172.16.5.0/24
  wg_admin: 172.16.250.0/24
  wg_paws: 172.16.251.0/24  # NEW EXAMPLE ONLY; actual paws subnet unknown
# Per physical subnet: router .1; DHCP .100-.150; static addresses outside DHCP.
dns_server: 172.16.5.53
api_vip: 172.16.3.30
gateway_vip: 172.16.3.200
load_balancer_pool: 172.16.3.200-172.16.3.219
nodes:
  core-cp01: 172.16.3.20
  core-cp02: 172.16.3.21
  core-cp03: 172.16.3.22
  core-wk01: 172.16.3.23
  core-wk02: 172.16.3.24
pod_cidr: 10.244.0.0/16     # new example; verify overlap with AWS/VPN
service_cidr: 10.96.0.0/12 # new example; verify overlap with AWS/VPN
public_applications: [backstage]
github_org: example-org
aws_region: us-east-1
active_eks_clusters: [forest-dev, foxbyte-dev]
dormant_eks_clusters: [forest-prd, foxbyte-prd]
secrets_backend: deferred
```

Add real NIC names/MACs, disk by-id paths, VM IDs, DNS authority, account-role mappings, endpoint accessibility, recovery owner and off-host backup destination in your private inventory. Use no live secrets in this contract.
