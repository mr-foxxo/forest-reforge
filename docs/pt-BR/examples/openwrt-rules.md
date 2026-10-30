# Padrões de regras OpenWrt

[English (default)](../../../examples/openwrt-rules.md) | [Português (Brasil)](openwrt-rules.md) | [Índice](../README.md)

São modelos de seções UCI, sem migração executável pronta. Substitua zonas pelos nomes inspecionados. `wg-paws-access` representa um plano de acesso, não necessariamente o identificador literal da zona. A zona paws precisa de INPUT ACCEPT ou permissões enumeradas; wg-admin deve rejeitar INPUT salvo funções locais explicitamente necessárias.

```uci
config rule 'paws_to_dns_host'
    option name 'Paws all services on DNS host'
    option src 'paws'
    option dest 'infra'
    option dest_ip '172.16.5.53'
    option proto 'all'
    option target 'ACCEPT'

config rule 'admin_to_dns'
    option name 'Admin DNS on independent resolver'
    option src 'wgadmin'
    option dest 'infra'
    option dest_ip '172.16.5.53'
    option dest_port '53'
    option proto 'tcp udp'
    option target 'ACCEPT'
```

A primeira regra libera todos os serviços somente em dns01; forwarding amplo paws → infra excede o requisito. A segunda libera DNS TCP/UDP 53 ao host independente. As descrições das regras foram preservadas como no exemplo compartilhado.

Audite IPv6 e regras ACCEPT anteriores que possam neutralizar a restrição. Valide sintaxe, preserve sessão de recuperação e execute a matriz do [módulo de rede](../modules/03-paths-network.md). Presença da regra não comprova política efetiva.
