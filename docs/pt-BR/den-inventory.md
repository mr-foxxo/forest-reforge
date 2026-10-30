# Inventário da Toca e alocações de recursos

[English (default)](../den-inventory.md) | [Português (Brasil)](den-inventory.md) | [Índice](README.md)

O inventário atual mantido pelo operador foi revisado em **30/10/2026**. Ele complementa as [imagens da plataforma](den-case-study.md) e o [registro de validações e experimentos](den-validations-experiments.md). Os IDs públicos seguem a convenção do projeto; aliases reais, endereços e inventário original permanecem privados. [observed-platform.json](../../examples/observed-platform.json) contém o registro estruturado compartilhado pelos dois idiomas.

## Participação na infraestrutura

| ID público | Plataforma ou função no inventário | Escopo Kubernetes |
|---|---|---|
| gw01 | Banana Pi R3, gateway/firewall, zona Boundary | Infraestrutura de rede |
| dns01 | Raspberry Pi 4, infraestrutura, zona Infra | Infraestrutura independente de rede/computação |
| hv01 | Dell PowerEdge R710 | Hospeda core-cp01–03 e core-wk01–04 |
| hv02 | Host X99 de dois sockets / V100 | Hospeda core-cp04–05 e core-wk05–08 |
| hv03 | Dell PowerEdge T310 | Infraestrutura integrada; não hospeda nós Kubernetes |
| hv04 | Dell PowerEdge T410 | Infraestrutura integrada; não hospeda nós Kubernetes |
| nas01 | Dell PowerEdge 2950 | Infraestrutura NAS independente |
| mgmt.hv01 | Gerenciamento IPMI de hv01 | Infraestrutura OOB |
| mgmt.hv02 | Gerenciamento IPMI/KVM de hv02 | Infraestrutura OOB |
| mgmt01 | Entrada de gerenciamento separada | Tipo, host pai, zona e recursos estão em branco neste inventário |

As descrições T310 e T410 identificam os dois hipervisores usados somente como infraestrutura; não acrescentam capacidade Kubernetes nem votantes etcd. A descrição do NAS complementa a imagem anterior do TrueNAS. A entrada de gerenciamento é preservada sem preencher lacunas por suposição. As imagens anteriores registram, separadamente, uma VM de gerenciamento em hv01.

## Alocações declaradas das VMs Kubernetes

As colunas da fonte são **vCPU** e **RAM**. A unidade da RAM **não foi informada**. Os números abaixo são preservados como registrados, sem conversão GB/GiB nem equivalência automática com capacidade atual do escalonador.

| Nó | Hipervisor | vCPU | Valor RAM (unidade não informada) | Observação do inventário |
|---|---|---|---|---|
| core-cp01 | hv01 | 2 | 8 | |
| core-cp02 | hv01 | 2 | 8 | |
| core-cp03 | hv01 | 2 | 8 | |
| core-cp04 | hv02 | 4 | 8 | |
| core-cp05 | hv02 | 4 | 8 | |
| core-wk01 | hv01 | 4 | 24 | |
| core-wk02 | hv01 | 4 | 24 | |
| core-wk03 | hv01 | 4 | 16 | |
| core-wk04 | hv01 | 4 | 16 | |
| core-wk05 | hv02 | 16 | 24 | Tesla V100 |
| core-wk06 | hv02 | 8 | 16 | |
| core-wk07 | hv02 | 16 | 24 | |
| core-wk08 | hv02 | 8 | 8 | |

| Escopo | VMs | Total de vCPU declaradas | Soma dos valores RAM (unidade não informada) |
|---|---|---|---|
| Control planes | 5 | 14 | 40 |
| Workers | 8 | 64 | 152 |
| Todas as VMs Kubernetes | 13 | 78 | 192 |
| Convidados Kubernetes em hv01 | 7 | 22 | 104 |
| Convidados Kubernetes em hv02 | 6 | 56 | 88 |

Os totais excluem overhead do hipervisor, outros convidados de infraestrutura e a entrada de gerenciamento sem recursos preenchidos. São alocações declaradas, não uso de CPU, requests/limits Kubernetes ou núcleos físicos. A nota V100 associa a GPU a core-wk05 no inventário; driver, modo de exposição, licença e resultados CUDA/modelo continuam em registros próprios.

## Conciliar inventário e medições

As **64 vCPU** declaradas para workers coincidem com as **64 CPU** de capacidade/alocável no painel anterior. Os **152 valores RAM sem unidade** e os **124,9 GiB de capacidade / 124,1 GiB alocáveis** do painel são registros distintos. Não substitua medições por totais de inventário nem diagnostique a diferença sem conferir configuração atual das VMs e dados dos Nodes.

Apenas a imagem selecionada de core-cp01 fornece medição individual: **2 CPU de capacidade/alocável**, **7,76 GiB de capacidade e 7,66 GiB de memória alocável**. O inventário agora lista alocações para todas as treze VMs, mas não fornece quantidades exatas da API Node para as outras doze. core-cp04 e core-cp05 têm **4 vCPU** declaradas, diferentes das **2 vCPU** de core-cp01–03.

Confira `qm list` e `qm config VMID` de cada host em registros privados, anotando unidade de memória, limites de ballooning e posicionamento atual. Compare uma exportação privada recente de Nodes com [cluster-resources.py](../../scripts/cluster-resources.py). Resolva a unidade RAM e possíveis divergências de configuração antes de redimensionar convidados ou declarar folga para novas cargas. Não compare somas de RAM dos convidados com GiB físicos sem estabelecer unidades e comportamento de memória.

## Usar o exemplo genérico

O [inventário do tamanho da Toca](../../automation/ansible/inventory.observed.example.yml) contém `reforge_hypervisor`, `reforge_inventory_vcpus`, `reforge_inventory_ram_value` e a nota opcional `reforge_inventory_gpu`. `reforge_inventory_ram_unit` permanece vazio. Esses campos documentam o inventário; não redimensionam VMs, configuram passthrough ou fazem hosts ingressarem no Kubernetes.

Endereços e interfaces de exemplo continuam como placeholders, sem copiar endpoints operacionais. Mantenha o mapeamento real de aliases/endereços em arquivos locais ignorados. Use [aceitação](acceptance.md) e o [registro de experimentos](den-validations-experiments.md) para resultados funcionais, falhas e recuperação.
