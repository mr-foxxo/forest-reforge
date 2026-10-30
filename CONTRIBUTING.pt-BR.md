# Como contribuir com o Forest Reforge

[English (default)](CONTRIBUTING.md) | [Português (Brasil)](CONTRIBUTING.pt-BR.md) | [Índice](docs/pt-BR/README.md)

Descreva o problema concreto, o comportamento resultante, as versões envolvidas, os testes e como reverter a mudança. Leia o módulo relevante, as [convenções de nomes](docs/pt-BR/naming.md), o [registro de decisões](docs/pt-BR/decisions.md) e o [guia de automação](docs/pt-BR/automation.md).

## Idiomas e organização

O inglês é o idioma padrão e a referência canônica. Atualize o documento em inglês e a alternativa em português do Brasil na mesma alteração quando o comportamento compartilhado mudar. As edições brasileiras são adaptadas e podem ser mais concisas; preserve pré-requisitos, limites, avisos e significado técnico. Se houver divergência, corrija a edição brasileira a partir do original inglês.

- `README.md`, `CONTRIBUTING.md` e `RELEASE.md` têm alternativas com sufixo `.pt-BR.md` na raiz.
- Guias em `docs/*.md` correspondem a `docs/pt-BR/*.md`.
- Módulos, exemplos e documentação de assets correspondem a `docs/pt-BR/modules/`, `docs/pt-BR/examples/` e `docs/pt-BR/assets/`.
- Mantenha os seletores de idioma e os índices [inglês](docs/README.md) e [brasileiro](docs/pt-BR/README.md). Prefira links locais no idioma escolhido.
- Preserve nomes de arquivo, comandos, opções, variáveis, chaves YAML/JSON, nomes de recursos e valores técnicos. Não duplique scripts, imagens ou configuração executável para traduzir a documentação.
- Execute os comandos a partir da raiz do repositório, salvo indicação contrária; a pasta do documento não altera o diretório de trabalho.

## Convenções e evidências

Use hosts por função, domínios de exemplo e IDs fictícios. Inventários reais, credenciais, fontes brutas e artefatos de execução ficam nos diretórios ignorados `local/` ou `reference/`. Remova dados privados de logs, diffs, capturas e descrições de PR.

Antes de publicar screenshots, revise conteúdo e metadados. Registre os originais públicos e hashes SHA-256 em [assets/evidence.json](assets/evidence.json), preserve pixels medidos e identifique explicitamente futuras versões com ocultações. Registre filtros, intervalo e unidades do painel.

Diferencie hosts físicos, hipervisores que hospedam Kubernetes, nós convidados, control planes e workers. Datas de revisão não substituem datas de captura. Para GPU, registre hardware, versões, modo de exposição, kernels reais da aplicação, temperatura, reinicialização e rollback no [registro da combinação](docs/pt-BR/examples/validated-stack.md).

Para rede e identidade, prove caminhos aceitos e rejeitados; para armazenamento, restaure dados; para AWS, registre conta/namespace e identidade de execução sem publicar identificadores reais. Automação deve declarar entradas, responsável pela reconciliação, idempotência e tratamento de falhas.

## Validação

Prepare o controlador conforme o [guia](docs/pt-BR/automation.md). Para alterações em helpers Python, templates, contratos ou empacotamento:

```bash
python -m unittest discover -s tests -v
```

Os testes AWS usam comandos simulados e precisam de jq. Para shell, execute `bash -n caminho/do/script.sh`. Para Ansible, com as coleções fixadas instaladas, a partir de `automation/ansible`:

```bash
for playbook in playbooks/*.yml; do
  ansible-playbook -i inventory.example.yml -e @site.example.yml "$playbook" --syntax-check || exit
done
ansible-playbook -i inventory.observed.example.yml -e @site.example.yml playbooks/main.yml --syntax-check
```

Em documentação, confira links relativos, âncoras, blocos de código e coerência com os exemplos. Em releases, gere um arquivo novo conforme [RELEASE.pt-BR.md](RELEASE.pt-BR.md), confira idiomas, licença, exclusões e checksum. Testes funcionais seguem o [guia de aceitação](docs/pt-BR/acceptance.md).

## Revisão e licença

Explique no PR o problema e o resultado final, testes e limitações, versões, mudanças de responsabilidade e reversão. Atualize as notas de release se mudar conteúdo distribuído ou comportamento. Preserve autoria, atribuição e avisos de terceiros sob a [GPL v3.0](LICENSE). Drivers, firmware, JARs e credenciais do operador seguem o fluxo de entradas privadas; distribua somente material autorizado.
