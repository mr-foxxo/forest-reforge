# 05 · Burrows — Proxmox e máquinas virtuais

[English (default)](../../../modules/05-burrows-proxmox.md) | [Português (Brasil)](05-burrows-proxmox.md) | [Índice](../README.md)

A fase `burrows` prepara IOMMU no bootloader selecionado. [proxmox-vm.sh](../../../scripts/proxmox-vm.sh) importa imagem verificada em VM nova parada. Consulte os [contratos privados](../automation.md).

## Instalação e isolamento

1. Garanta console OOB/local e mídia de recuperação.
2. Escolha Proxmox/kernel a partir dos requisitos GPU, registrando versões exatas.
3. Confira discos de destino antes da instalação destrutiva.
4. Configure hora, DNS, hostname e repositórios compatíveis com release/subscrição.
5. Relacione bridges a ligações físicas; não una OOB e zonas de workloads.
6. Crie administrador com papel adequado e recuperação local protegida.
7. Prepare backup independente e restaure um convidado pequeno antes do cluster.

VM na bridge Servers participa daquele L2; VM em outra bridge não anuncia automaticamente VIP Servers por ARP.

## Contrato dos convidados

Use imagem/checksum fixados, cloud-init, VirtIO, guest agent, recursos definidos, MAC/IP estáveis, DNS/NTP conhecidos e chaves SSH. Clone antes de kubeadm para garantir identidade única. CPU `host` ajuda instruções mas limita migração heterogênea. GPU passthrough vincula VM ao dispositivo salvo suporte de migração comprovado. Verifique NUMA e localidade PCI/memória.

O [inventário atual](../den-inventory.md) declara 2 vCPU em core-cp01–03, 4 em core-cp04–05 e workers heterogêneos somando 64 vCPU. Convidados Kubernetes totalizam 22 vCPU em hv01 e 56 em hv02. A coluna RAM não informa unidade; somas de 104 e 88 por host não são diretamente comparáveis aos 125,87/62,65 GiB físicos dos painéis anteriores. Confira unidade/configuração atual antes de dimensionar. Os 7,66 GiB alocáveis medidos em core-cp01 e os 124,1 GiB do painel de workers permanecem registros separados. Reserve memória para hosts, caches e outros convidados; KSM não é RAM física adicional.

## Kernel, passthrough e recuperação

Identifique bootloader e grupos IOMMU antes de alterar parâmetros. Preserve kernel conhecido e config. Isole somente BDF pretendido, sem capturar dispositivos necessários ao host; não aplique ACS override como solução automática. Confirme reset/reinício da GPU e console virtual até provar acesso alternativo.

Faça canário com backup, teste workload real e inicialização pelo kernel anterior antes de ampliar atualização. Aceitação exige VM restaurada, rede correta, IOMMU observado e reversão documentada. O original inglês detalha o ciclo completo de manutenção.
