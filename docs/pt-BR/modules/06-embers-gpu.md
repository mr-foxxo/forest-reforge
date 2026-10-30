# 06 · Embers — GPUs antigas, passthrough e vGPU

[English (default)](../../../modules/06-embers-gpu.md) | [Português (Brasil)](06-embers-gpu.md) | [Índice](../README.md)

Use a fase `embers`, [gpu-diagnose.sh](../../../scripts/gpu-diagnose.sh), [kernel-gate.sh](../../../scripts/kernel-gate.sh), [gpu-driver.sh](../../../scripts/gpu-driver.sh) e [vgpu-attach.sh](../../../scripts/vgpu-attach.sh). Revise a [matriz](../compatibility.md) e o [runbook P4](../r710-p4-vgpu-runbook.md).

## Escolher o modo

Passthrough completo atribui a placa a um convidado e é o primeiro experimento mais simples. vGPU requer suporte da GPU, manager, hypervisor, kernel, driver convidado e licença como conjunto. M40 não tem suporte oficial; P4 termina no branch 16; V100 tem variantes listadas no branch 19 no registro pesquisado. Não misture receitas Pascal e Volta.

## Qualificação

1. Confirme identidade PCI completa/BDF, VRAM, alimentação, riser e refrigeração.
2. Preserve console e kernel conhecido. Registre kernel/headers, drivers e checksums.
3. Em passthrough, verifique grupo IOMMU e binding VFIO apenas dos dispositivos pretendidos. Em vGPU, o host usa manager apropriado e perfis nativos.
4. Instale primeiro o pacote original qualificado; guarde o primeiro erro antes de considerar patch específico, com diff/proveniência.
5. Confira módulo/assinatura, manager e disponibilidade de perfil. Taint proprietário ou serviço oneshot inactive não basta para concluir falha.
6. Anexe à VM parada, mantendo VGA virtual e acesso remoto. Descubra ID numérico de perfil localmente.
7. Instale driver convidado correspondente e licença legítima; não substitua por driver incluído em outro bundle CUDA.
8. Execute operação CUDA, kernels reais da aplicação, reinícios da VM e reboot do host. Meça temperatura, potência, estabilidade e erros PCIe/Xid.

Extração do instalador executa código do fornecedor; use material confiável e autorizado. Não há bypass de licença, patch inventado, purge amplo ou reboot automático.

## Interpretação dos resultados

`nvidia-smi` não comprova toolkit instalado nem suporte do framework ao modelo. CUDA compiler, runtime, wheel, operadores e CPU têm limites distintos. Containers não restauram arquiteturas removidas ou AVX ausente. Preencha o [registro da combinação](../examples/validated-stack.md) antes de declarar validação. Falhou após update: retorne ao conjunto anterior completo, preservando logs e configuração para diagnóstico.
