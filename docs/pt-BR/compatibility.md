# Compatibilidade de GPUs antigas

[English (default)](../compatibility.md) | [Português (Brasil)](compatibility.md) | [Índice](README.md)

Registro baseado na documentação primária consultada em **27/10/2026**, preservando o escopo histórico do original. São limites de suporte e orientações de qualificação, sem resultados de benchmark local.

| GPU | Arquitetura / CUDA CC | Limite oficial de vGPU registrado | Primeiro experimento |
|---|---|---|---|
| Tesla M40 | Maxwell / 5.2 | Sem suporte oficial | Passthrough completo e aplicação legada fixada |
| Tesla P4 | Pascal / 6.1 | Branch 16; manutenção indicada até julho de 2026 | Passthrough; vGPU legado como experimento explícito |
| Tesla V100 | Volta / 7.0 | Branch 19 para variantes listadas | Passthrough ou combinação vGPU qualificada |

Confirme variante, VRAM e formato: V100 SXM não é placa PCIe comum. Aparência e encaixe não comprovam pinagem, potência ou refrigeração compatíveis.

## Verificações independentes

Verifique chassis/riser/energia, kernel e headers exatos, APIs do módulo e assinatura de boot, suporte do driver, matriz manager/hypervisor/guest/licença, toolkit que compila a arquitetura, kernels incluídos no framework, operadores do modelo e instruções da CPU.

O registro original informa que CUDA 13 removeu compilação offline abaixo de CC 7.5; essas placas precisam de toolkit anterior compatível (12.9 ou anterior) e revisão da aplicação que preserve seus kernels. Suporte de compilação é diferente de suporte de execução pelo driver. A referência a R580 não certifica qualquer combinação de sistema e vGPU.

Os módulos abertos NVIDIA atendem Turing ou posterior; M40/P4/V100 exigem o módulo proprietário adequado. O mínimo CC 7.5 documentado para vLLM na revisão exclui as três; o histórico 0.7.3, com CC 7.0, permite estudar V100 sem garantir todos os modelos. Containers não emulam AVX/AVX2 ausentes no host.

## Registro obrigatório

Preencha o [modelo de stack](examples/validated-stack.md) com GPU/PCI/VRAM, chassis/riser, BIOS, Proxmox, kernel/headers, checksums de drivers e patches, sistema/driver convidado, licença, CUDA, framework/flags, digest da imagem, hash/quantização do modelo, testes, temperatura e rollback. `nvidia-smi` isoladamente não valida inferência.

As [referências primárias](upstream.md) e o [original inglês](../compatibility.md) registram as fontes desta matriz. Revalide a documentação do fabricante ao selecionar uma combinação nova.
