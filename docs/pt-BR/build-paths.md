# Caminhos de implantação e pré-requisitos

[English (default)](../build-paths.md) | [Português (Brasil)](build-paths.md) | [Índice](README.md)

| Caminho | Mínimo | Resultado | Limite |
|---|---|---|---|
| Seed | Host estável, DNS/roteador e disco de backup | VMs e laboratório CPU/GPU | Sem alta disponibilidade física |
| Grove | Vários hosts, gerenciamento isolado e backup externo | Kubernetes, GitOps e portal | Quórum e armazenamento exigem projeto explícito |
| Skybridge | Grove, contas AWS e acesso VPN/API | Entrega local e EKS pelo Toca | Custos e dependências da nuvem |

GPU e AWS são opcionais. Qualifique GPUs em VMs isoladas antes de levar inferência ao Kubernetes.

## Ordem de execução

1. Preencha inventário, [contrato do ambiente](examples/site-contract.md) e [registro de versões](examples/validated-stack.md); elimine sobreposição de CIDRs e IPs duplicados.
2. Monte rack, energia, refrigeração e identificação; inspecione e meça a carga.
3. Teste RAM, discos e firmware até obter estabilidade repetível.
4. Prepare OOB, DNS, OpenWrt e VPN; teste recuperação e acessos rejeitados.
5. Configure Proxmox, bridges, backups e templates; restaure uma VM descartável.
6. Valide uma VM com passthrough e execução real de CUDA, caso use GPU.
7. Instale kubeadm, kube-vip, Cilium e Gateway API; teste API, DNS, rede entre nós e VIP.
8. Configure armazenamento, cert-manager e DNS canônico; teste persistência e TLS.
9. Instale Argo, métricas, políticas básicas e backup externo; valide sincronização de commit.
10. Transfira os recursos escolhidos para GitOps, eliminando dupla reconciliação.
11. Prepare Backstage, banco e catálogo GitHub; teste identidade e permissões internamente.
12. Publique Backstage via Cloudflare após provar rejeição de usuários não autorizados.
13. Configure contas, roles, redes e registro EKS; teste implantação permitida e namespace proibido.
14. Expanda logs, IA e capacidade conforme medições, recuperação e custo.

O [guia de automação](automation.md) descreve as fases implementadas e suas entradas privadas. Os nomes de playbooks históricos preservam evidência, sem substituir o fluxo atual.

## Quando interromper

Interrompa diante de erros de memória, discos defeituosos, limitação térmica, pinagem desconhecida, ausência de rollback, CIDRs sobrepostos ou credenciais excessivas. Resolva o pré-requisito antes de adicionar camadas.
