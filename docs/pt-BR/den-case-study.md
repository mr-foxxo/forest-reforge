# Toca: plataforma observada

[English (default)](../den-case-study.md) | [Português (Brasil)](den-case-study.md) | [Índice](README.md)

Revisão de **28/10/2026**, com sete imagens iniciais, dez complementares e esclarecimentos do proprietário. Data de revisão não substitui captura. IDs por função ocultam nomes privados; dois [originais públicos](assets/README.md) preservam os pixels. O [snapshot JSON](../../examples/observed-platform.json) mantém os dados estruturados.

A revisão do **inventário do operador em 30/10/2026** acrescenta plataformas, entradas de infraestrutura e alocações declaradas de cada VM. O [guia de inventário e recursos](den-inventory.md) apresenta as treze linhas e seus totais. Declarações do inventário e medições anteriores preservam fontes e unidades separadas.

## Infraestrutura física

CPU significa processadores lógicos; RAM significa total utilizável exibido, sem inferir capacidade dos DIMMs.

| Host | Plataforma no inventário | CPU | Sockets / CPU lógicas | RAM utilizável | Proxmox | Kernel | Boot | Hospeda Kubernetes |
|---|---|---|---|---|---|---|---|---|
| hv01 | Dell PowerEdge R710 | X5690 | 2 / 24 | 125,87 GiB | 9.2.4 | 7.0.14-5-pve | BIOS legado | Sim |
| hv02 | X99 de dois sockets | E5-2698 v3 | 2 / 64 | 62,65 GiB | 9.2.18 | 7.0.14-16-pve | EFI | Sim |
| hv03 | Dell PowerEdge T310 | X3430 | 1 / 4 | 15,61 GiB | 9.2.2 | 7.0.2-6-pve | BIOS legado | Não |
| hv04 | Dell PowerEdge T410 | X5660 | 1 / 12 | 23,46 GiB | 9.2.2 | 7.0.2-6-pve | BIOS legado | Não |

Os hosts Kubernetes somam 88 CPU lógicas e 188,52 GiB utilizáveis. Isso não equivale à capacidade alocável dos convidados. Uso, cache, KSM e overcommit exigem contabilidade separada. Os cerca de 94 GiB de `/` não representam todos os datastores. Kernels 7.x observados não comprovam compatibilidade com managers vGPU antigos.

O inventário identifica `nas01` como Dell PowerEdge 2950. O painel anterior exibe TrueNAS Community 25.10.7 – Goldeye, Xeon E5410 e 23,5 GiB ECC disponível. Dois pools ONLINE, cada um com um disco, mostram zero erros e indicadores de scrub verdes. Não há evidência de redundância, exportação Kubernetes, execução de backup ou restauração. Espaço livre exibido: 465,61 GiB e 1,76 TiB. O inventário associa uma Tesla V100 a core-wk05, sem substituir os registros de driver/CUDA.

## Kubernetes e posicionamento

São 13 nós Ready com kubelet v1.36.4: cinco control planes e oito workers. Cada control plane mostra um taint, sem chave/efeito legíveis; workers mostram zero. hv01 hospeda cp01–03/wk01–04; hv02 hospeda cp04–05/wk05–08. Ambos são Proxmox standalone, sem cluster Proxmox HA.

Se os cinco control planes forem votantes stacked-etcd, a maioria é três: perda de hv01 deixa dois; perda de hv02 deixa três. Trata-se de análise condicional de topologia, sem teste de falha concluído. core-cp01 mostra 2 CPU e memória capacity/allocatable de 7,76/7,66 GiB; não generalize aos outros nós.

O inventário atual lista alocações declaradas para as treze VMs: **14 vCPU nos control planes e 64 nos workers, totalizando 78**. core-cp04–05 têm **4 vCPU**, enquanto core-cp01–03 têm **2**. A coluna RAM soma **40 + 152 = 192**, sem unidade informada. Essas declarações não fornecem quantidades exatas da API Node para os outros doze nós.

O painel abaixo é **restrito aos workers**:

| Recurso | Uso | Requests | Limits | Alocável | Capacidade |
|---|---|---|---|---|---|
| CPU | 1,45 | 7,88 | 49,85 | 64 | 64 |
| RAM GiB | 17,2 | 29,0 | 99,0 | 124,1 | 124,9 |
| Pods | 116 | Não exibido | Não exibido | 880 | 880 |

Diferenças aritméticas de valores arredondados não garantem agendamento. Afinidades, taints, LocalPV, fragmentação e reserva para falhas continuam relevantes. Não some RAM física à RAM alocável das VMs nem misture esses totais com outros painéis.

Os 152 valores RAM declarados para workers não substituem os 124,9 GiB de capacidade / 124,1 GiB alocáveis do painel. Confira unidade de memória, configuração atual das VMs e exportação recente de Nodes conforme a [conciliação do inventário](den-inventory.md#conciliar-inventário-e-medições).

## Atualizar as evidências

No controlador preparado conforme [automação](automation.md):

```bash
python scripts/cluster-resources.py --context YOUR_PRIVATE_CONTEXT \
  --expect examples/observed-platform.json

umask 077
kubectl --context YOUR_PRIVATE_CONTEXT get nodes -o json > local/nodes.json
python scripts/cluster-resources.py --nodes-json local/nodes.json \
  --expect examples/observed-platform.json
```

O helper lê Nodes e emite agregados sem nomes, endereços ou credenciais; não escreve no cluster nem lê Secrets/Pods. Código 0: verificações solicitadas aprovadas; 1: diferença de saúde/snapshot; 2: falha de entrada/coleta. Atualização intencional pode divergir. Em outro ambiente, use perfil próprio ou omita `--expect`.

Métricas de uso/requests/limits e posicionamento exigem fontes separadas. Consulte os [experimentos](den-validations-experiments.md), o [inventário observado](../../automation/ansible/inventory.observed.example.yml) e a [aceitação](acceptance.md).
