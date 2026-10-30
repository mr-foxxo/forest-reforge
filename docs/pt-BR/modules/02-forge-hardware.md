# 02 · Forge — qualificação do hardware

[English (default)](../../../modules/02-forge-hardware.md) | [Português (Brasil)](02-forge-hardware.md) | [Índice](../README.md)

Use os helpers compartilhados [host-audit.sh](../../../scripts/host-audit.sh) e [gpu-diagnose.sh](../../../scripts/gpu-diagnose.sh). O [snapshot](../den-case-study.md) melhora o dimensionamento, sem provar estabilidade de DIMMs, potência ou workloads GPU.

## R710 e CPU

O relato descreve R710 revisão II, dois X5690, fontes 870 W, iDRAC6 Enterprise, Riser 2 x16 e uma P4 instalada. Registre revisão do manual, part number do riser, pinagem/limite do slot, bracket, firmware e refrigeração. Slot x16 físico não prova potência nem número de lanes.

X5690 não possui AVX. Confira `lscpu` e binários; containers não emulam instruções ausentes. Capture PCI primário e subsystem antes de binding; consulte o [runbook R710/P4](../r710-p4-vgpu-runbook.md).

## Memória X99: teste repetível

A história mistura módulos Corsair de 32/16 GB e revisões distintas, com um módulo suspeito e POST 60 em um slot. A causa não foi concluída; cores e códigos dependem da motherboard.

1. Registre BIOS e configurações; desligue alimentação antes de mover DIMMs e identifique módulos/slots.
2. Use defaults conservadores, sem XMP/overclock, e JEDEC/ordem de população previstos nos manuais.
3. Teste módulo conhecido no slot primário por múltiplas passagens completas; registre versão, duração e erros.
4. Fixe slot e varie módulos; depois fixe módulo e varie slots/canais suportados.
5. Teste conjuntos correspondentes antes da mistura e aumente população gradualmente.
6. Se falhar por canal, investigue pinos, assentamento, pressão do cooler e dependências CPU/canal.
7. Repita população final a frio e a quente. Meta: zero erros; mantenha a configuração mínima conhecida para retorno.

## Discos, firmware e console

Registre modo do controlador, firmware, SMART, erros de link e topologia. RAID pode ocultar saúde individual; não execute teste destrutivo em dados existentes. Atualização de firmware precisa corresponder à plataforma e preservar recuperação.

O caso DRAC5 confirmou JNI i386, JNLP manual recente e opção **Pass all keystrokes to target**. Não aplique automaticamente essa receita ao iDRAC6; inspecione seus artefatos próprios. Veja o [procedimento de console](../drac5-apple-silicon-runbook.md).
