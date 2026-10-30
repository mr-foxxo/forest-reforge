# Modelo de contrato do ambiente

[English (default)](../../../examples/site-contract.md) | [Português (Brasil)](site-contract.md) | [Índice](../README.md)

**Exemplo proposto, sem representar inventário real confirmado do local de origem.** Substitua valores conscientemente antes de executar comandos. `example.net` não permite emitir seu próprio certificado ACME. Preserve as chaves de configuração em inglês.

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
  wg_paws: 172.16.251.0/24  # SOMENTE EXEMPLO NOVO; subnet paws real desconhecida
# Por subnet física: roteador .1; DHCP .100-.150; IPs estáticos fora do DHCP.
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
pod_cidr: 10.244.0.0/16     # exemplo novo; conferir sobreposição com AWS/VPN
service_cidr: 10.96.0.0/12 # exemplo novo; conferir sobreposição com AWS/VPN
public_applications: [backstage]
github_org: example-org
aws_region: us-east-1
active_eks_clusters: [forest-dev, foxbyte-dev]
dormant_eks_clusters: [forest-prd, foxbyte-prd]
secrets_backend: deferred
```

Acrescente no inventário privado NICs/MACs reais, discos por caminho by-id, VMIDs, autoridade DNS, relação entre contas/roles, acessibilidade de endpoints, responsável por recuperação e destino de backup fora dos hosts. Não coloque segredos ativos neste contrato.

Use o [guia de automação](../automation.md) para preencher o contrato executável em `local/site.yml`; este modelo descreve o ambiente e não substitui todas as variáveis Ansible.
