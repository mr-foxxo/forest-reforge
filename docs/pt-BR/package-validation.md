# Validação do pacote

[English (default)](../package-validation.md) | [Português (Brasil)](package-validation.md) | [Índice](README.md)

Registro da revisão original de **28/10/2026**. Verificações offline do repositório e observações de screenshots têm escopo diferente da aceitação de uma implantação. Os números abaixo descrevem aquela revisão; não são uma execução automática ao ler este documento.

Atualização de conciliação em **30/10/2026**: os [guias de inventário nos dois idiomas](den-inventory.md) e o perfil compartilhado agora registram alocações declaradas das treze VMs, plataformas e entradas independentes de infraestrutura. A unidade da RAM continua não informada. Valores das tabelas EN/pt-BR e metadados YAML são conferidos com o registro comum; medições anteriores dos Nodes permanecem separadas.

Nesta atualização, os 25 testes passaram novamente, `main.yml` teve sintaxe aprovada com o inventário da Toca atualizado, e links/blocos de código foram conferidos em 78 arquivos Markdown EN/pt-BR. As treze linhas de alocação e os totais por função/host coincidem entre as duas tabelas, JSON e YAML.

## Verificações registradas

- 25 testes offline: helpers, comandos AWS simulados, contratos de configuração/identidade, recursos e posicionamento, integridade de imagens, privacidade e empacotamento.
- 15 playbooks com sintaxe aprovada; `main.yml` também com inventário de cinco control planes/oito workers. Roles de contrato rejeitaram entradas sintéticas não revisadas e contexto incorreto.
- 16 templates renderizados e YAML analisado nos dois modos opcionais, incluindo ACME, Dex, TLS de banco, pull Secret e kube-vip.
- 17 helpers shell e entrypoint DRAC5 com `bash -n` aprovado.
- Launcher Java compilado para Java 8; Compose validado com entradas sintéticas, sem baixar/construir imagem.
- Links Markdown, destinos de imagens e blocos de código conferidos; exemplos AWS analisados como JSON.
- Pacote público inspecionado e teste com sentinelas privadas confirmou exclusões.
- Sete imagens iniciais e dez complementares revisadas; dois originais públicos com hashes/metadados e correspondência de manifesto verificados.

## Reproduzir

Prepare o controlador conforme [automação](automation.md), então na raiz:

```bash
. .venv/bin/activate
python -m unittest discover -s tests -v
```

Testes AWS são simulados e precisam de jq; sem ele há skip explícito. Para Ansible, com coleções fixadas, em `automation/ansible`:

```bash
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory.example.yml -e @site.example.yml "$playbook" --syntax-check || exit
done
```

Para documentação, confira índices dos dois idiomas, links, âncoras, blocos de código e correspondência com exemplos executáveis. Gere pacote novo conforme [release](../../RELEASE.pt-BR.md), confira idiomas, `LICENSE`, exclusões e checksum.

## Limites

A revisão original não acessou ou alterou hosts, GPU, BMC, roteador, cluster ou conta AWS. Não certificou versão-alvo de chart/pacote, datapath CNI, login, restauração, compilação de driver, sessão JNI ou autorização de nuvem. Check mode é parcial e scans não garantem ausência de todo segredo.

Checker de Nodes não atualiza queries dos painéis nem estabelece posicionamento físico. Apenas core-cp01 tem dimensionamento individual observado. JDK, JARs proprietários, drivers, imagem Backstage, identidade AWS e contrato privado são entradas do operador. Medidas do rack, patch GPU final e login automático DRAC5 permanecem sem confirmação. Consulte a [aceitação funcional](acceptance.md).
