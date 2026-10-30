# 03 · Paths — segmentação e WireGuard

[English (default)](../../../modules/03-paths-network.md) | [Português (Brasil)](03-paths-network.md) | [Índice](../README.md)

## Mapa proposto

| Porta/interface | Zona | Rede de exemplo |
|---|---|---|
| lan1 | clients | 172.16.1.0/24 |
| lan2 | oob | 172.16.2.0/24 |
| lan3 | servers | 172.16.3.0/24 |
| lan4 | vms | 172.16.4.0/24 |
| WAN/LAN cobre | infra | 172.16.5.0/24 |
| SFP1/SFP2 | wan | Depende do provedor |
| wg0 | wg-admin | 172.16.250.0/24 |
| WG separado | wg-paws-access | Valor privado, não confirmado na fonte |

Gateways físicos `.1`, DHCP `.100–.150`. Confira dispositivos lógicos OpenWrt: nomes impressos nas portas não garantem nomes UCI.

## Política e aplicação

Paws pode administrar o roteador e acessar todos os serviços de dns01 `172.16.5.53`; acesso aos demais hosts deve ser explícito. wg-admin não administra o roteador em **nenhum** IP local, recebe DNS TCP/UDP 53 e apenas destinos/portas concedidos. Clientes/workloads não acessam OOB. Conector Cloudflare acessa Gateway 443, DNS e egress necessário. WAN não publica gerenciamento, resolver ou DNAT HTTP de origem.

1. Abra sessão independente local/paws e faça backup privado de rede/firewall.
2. Inspecione UCI, endereços, rotas e regras sem publicar dados privados.
3. Relacione interfaces às zonas e elimine bridges indevidas após conferir cabeamento.
4. Diferencie INPUT local de FORWARD roteado; aplique defaults conservadores e permissões específicas.
5. Remova ACCEPT amplo de wg-admin para gerenciamento do roteador; bloquear um IP não basta.
6. Restrinja AllowedIPs, DNS, destinos e firewall de cada peer. AllowedIPs não substitui autorização.
7. Valide sintaxe (`fw4 check` quando disponível), aplique pela sessão recuperável e teste de clientes independentes.
8. Teste paws, rejeição SSH/LuCI de wg-admin em todos os IPs, DNS TCP/UDP e serviços permitidos; em falha, restaure.

Não bloqueie o listener WireGuard WAN ao restringir administração pelo túnel. Audite IPv6 separadamente. Use os [padrões UCI](../examples/openwrt-rules.md) após inspecionar o ambiente.

Confirme rotas de ida/volta e DNS do peer. Se pedidos pequenos funcionam e transferências travam, investigue PMTU. Mantenha CIDRs LAN, VPN, pods, services e AWS sem sobreposição, registrando rotas ou SNAT efetivos.
