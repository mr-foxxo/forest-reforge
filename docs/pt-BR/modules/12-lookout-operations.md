# 12 · Lookout — operação e recuperação

[English (default)](../../../modules/12-lookout-operations.md) | [Português (Brasil)](12-lookout-operations.md) | [Índice](../README.md)

`lookout` instala monitoramento e controladores opcionais; `backup` agenda snapshot por [etcd-backup.sh](../../../scripts/etcd-backup.sh). [cluster-troubleshoot.sh](../../../scripts/cluster-troubleshoot.sh) coleta condições sem valores de Secrets.

## Observar

Monitore temperatura/ECC/discos, pressão dos hosts e VMs, API/etcd, capacidade, drops Cilium, VIPs, certificados, banco, Argo, Tunnel, pulls e idade dos backups. A base usa kube-prometheus-stack e Hubble; Loki/Alloy exigem versões, retenção e valores explícitos. Exporters GPU devem ser compatíveis com a placa/driver, sem presumir DCGM.

Registre filtros, janela, unidades e query por painel. Evite labels de alta cardinalidade e dados sensíveis em logs. O checker de Nodes atualiza contagens/capacidade, sem refazer queries dos [painéis públicos](../den-validations-experiments.md).

## Backup

| Área | Material necessário |
|---|---|
| Rede/DNS | Configuração, zonas e segredos VPN/TSIG protegidos |
| Proxmox | Configuração host/VM, layout e backups de convidados |
| Kubernetes | Snapshot etcd, PKI, chave/config de criptografia e bootstrap |
| GitOps | Repositório, artefatos fixados e recuperação das credenciais |
| Dados | Backups PostgreSQL com roles/chaves; objetos com metadados |
| Identidade | Conta de recuperação e acesso às chaves/provedor |

Timer local não basta: copie fora do cluster/host/rack, criptografe, verifique integridade e preserve chave recuperável separadamente. Defina e meça RPO/RTO por necessidade real. ONLINE no NAS não prova restore.

## Ordem de restauração

1. Energia e rede física.
2. DNS independente, hora e acesso de recuperação.
3. Hipervisores, armazenamento e serviços essenciais.
4. Control plane com backup e PKI/chave correspondentes.
5. Cilium, Gateway, certificados e segredos iniciais.
6. Argo e reconciliação.
7. Dados, portal e workloads.
8. Integrações de nuvem, acesso externo e testes de segurança/dados.

Faça exercícios isolados para evitar VIPs/controladores duplicados. Restauração etcd segue versão e membership próprios, sem copiar diretório de dados vivo arbitrário.

## Manutenção e limpeza

Por mudança: diff, backup, versão fixada, canário de um nó, workload e rollback. Sugestões periódicas: frescor de backup, erros de disco/temperatura, expiração, restore amostral, patches, custos e acessos. São orientações, sem agendamentos criados automaticamente.

Inspecione namespace/PVC antes de excluir teste. Não limpe firewall ou `/var/openebs` para corrigir rota HTTP. Desfaça cordon só dos nós alterados pelo teste. Mantenha instruções e credenciais de recuperação fora do Backstage. Veja [aceitação](../acceptance.md).
