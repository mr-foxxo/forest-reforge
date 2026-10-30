# 13 · Spellwork — IA em hardware antigo

[English (default)](../../../modules/13-spellwork-ai.md) | [Português (Brasil)](13-spellwork-ai.md) | [Índice](../README.md)

**Fluxo proposto de qualificação**, sem promessa de tokens/s, tamanho de modelo ou potência medida na Toca. [spellwork-build.sh](../../../scripts/spellwork-build.sh) compila checkout revisado em commit exato; toolkit e revisão precisam preservar os alvos.

## Escolher workload

Comece pequeno, com contexto curto. VRAM inclui pesos, KV cache, buffers, concorrência e alocações do framework. Quantização altera memória e comportamento numérico; seu kernel pode exigir arquitetura mais nova. Não imponha BF16/FP8 ou atenção fundida moderna a todas as placas.

Consulte a [compatibilidade](../compatibility.md): M40/P4/V100 têm CC 5.2/6.1/7.0. O mínimo CC 7.5 de vLLM registrado exclui as três; revisão antiga para V100 é experimento específico. Container moderno não recria alvos CUDA ou kernels removidos.

## Experimento llama.cpp

Em VM isolada, com checkout já revisado e toolkit compatível, escolha um alvo (M40=52, P4=61, V100=70):

```bash
cmake -S . -B build-reforge \
  -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=70 \
  -DGGML_NATIVE=OFF
cmake --build build-reforge --config Release -j 4
```

`GGML_NATIVE=OFF` sozinho não garante X5690: confira flags AVX/AVX2/FMA e comando real do compilador. Use revisão que preserve kernels desejados. Inspecione `--help` do binário e parâmetros de modelo/offload/contexto dessa versão. Sirva em loopback/rede privada até configurar autenticação, limites e rotas.

## Diagnóstico e benchmark

No framework pretendido, registre versão, CUDA runtime, dispositivo, capability e arquiteturas compiladas. Execute operação pequena, sincronize e confira resultado; depois teste atenção, quantização e sampling reais. `no kernel image is available` sugere arquitetura ausente; `Illegal instruction` pode ser CPU; OOM exige rever todas as alocações.

Registre licença/hash do modelo, tokenizer, quantização, prompts/dataset, contexto/saída, seed, aquecimento, repetições e clientes concorrentes. Meça primeiro token, throughput de prompt e geração separadamente, p50/p95, erros, picos VRAM/RAM, potência na tomada e temperatura estável. Compare a mesma carga e qualidade.

Passthrough/vGPU/CPU precisam de versões e recursos registrados para comparação. Em Kubernetes, valide device plugin/operator com driver, labels/taints e requests GPU antes de agendar. Preserve fallback VM. Use o [modelo de stack](../examples/validated-stack.md); o [original inglês](../../../modules/13-spellwork-ai.md) contém o diagnóstico PyTorch executável.
