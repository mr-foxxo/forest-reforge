# R710 com P4: procedimento experimental do host

[English (default)](../r710-p4-vgpu-runbook.md) | [Português (Brasil)](r710-p4-vgpu-runbook.md) | [Índice](README.md)

## Evidência e limites

A conversa de 22 de julho relata R710 revisão II, dois X5690, duas fontes 870 W e P4 no Riser 2 x16. A proposta final usa **vGPU 16.14 / Linux KVM Manager 535.309.01**. O proprietário relatou instalação do driver e término bem-sucedido de `vgpud`; faltam kernel exato desse teste, logs completos, patch final e CUDA no convidado. É um marco de host relatado, sem stack integralmente validada.

A captura posterior mostra Proxmox 9.2.4/kernel 7.0.14-5-pve em hv01, sem evidência de driver/perfil. Não associe automaticamente essa captura ao marco 535.309.01. A proposta V100 19.5/580.159.01 é separada.

## Identificação e pré-requisitos

Capture `lspci -Dnnk` completo: o relato `10de:11d8` foi interpretado como subsystem; o device primário esperado da P4 é `10de:1bb3`. Confirme BDF, riser, limite elétrico e refrigeração. Fonte potente e limitação por software após inicialização não qualificam transientes ou suporte elétrico do slot.

## Sequência do host

1. Preserve console local/iDRAC, configuração e kernel inicializável conhecido. Não combine o experimento com atualização geral.
2. Registre `pveversion -v`, `uname -r`, firmware, bootloader, PCI, DKMS e Secure Boot.
3. Instale headers/ferramentas correspondentes à versão exata. Inspecione efeitos de helpers antes de executá-los.
4. Verifique IOMMU no bootloader correto, preservando opções e dispositivos VFIO não relacionados.
5. Para vGPU mediada, remova somente o binding VFIO da placa escolhida e conflitos de driver identificados; sem purge por wildcard.
6. Obtenha legitimamente `NVIDIA-Linux-x86_64-535.309.01-vgpu-kvm.run`, valide checksum e preserve original privado. Driver compute comum não substitui KVM Manager.
7. Teste instalação original com DKMS. Se falhar, guarde o primeiro erro e logs; não reinicie com substituição incompleta.
8. Aplique somente patch ligado ao erro e API do kernel, com origem, diff e checksum registrados. Verifique `nvidia` e `nvidia_vgpu_vfio` no kernel pretendido.
9. Reinicie pelo caminho recuperável; confirme binding, driver, manager e perfis nativos antes de testar VM parada.

Famílias de erro históricas envolvem VMA (`nv-mmap.c`), DMA fence (`nvidia-dma-fence-helper.h`), opções DRM e IRQ bypass VFIO (`nvidia-vgpu-vfio.c`). O [original detalhado](../r710-p4-vgpu-runbook.md) preserva o mapa; nenhum patch final foi fornecido. Código dos módulos abertos pode informar comparação de API, sem torná-los executáveis em Pascal.

## Resultado dos serviços

```bash
systemctl show nvidia-vgpud.service \
  -p Type -p ActiveState -p SubState -p Result -p ExecMainStatus
systemctl show nvidia-vgpu-mgr.service \
  -p Type -p ActiveState -p SubState -p Result -p ExecMainStatus
nvidia-smi
modinfo nvidia_vgpu_vfio
mdevctl types
```

`vgpud` pode terminar com código 0 enquanto o manager continua ativo. Estado inactive e taint de módulo proprietário, isoladamente, não demonstram falha. Examine resultado, logs, Xid/PCIe e disponibilidade de perfis.

## Primeiro convidado

A proposta inicial, sem resultado confirmado, usa q35/OVMF, VGA virtual preservada, CPU host, um socket/quatro cores, 16 GiB sem ballooning, disco de pelo menos 64 GB e VirtIO. P4-4Q só se disponível e adequado à licença/workload. Descubra ID mdev numérico localmente e anexe com VM parada.

Instale driver GRID convidado correspondente e licença legítima; evite substituí-lo pelo driver de um bundle CUDA. Teste driver → licença → operação CUDA → aplicação → reinícios da VM → reboot do host, medindo temperaturas e erros. Registre tudo no [modelo de stack](examples/validated-stack.md).
