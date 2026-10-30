# Notas de release

[English (default)](RELEASE.md) | [Português (Brasil)](RELEASE.pt-BR.md) | [Índice](docs/pt-BR/README.md)

## Documentação em dois idiomas

O inglês permanece padrão. O pacote inclui `README.pt-BR.md`, `CONTRIBUTING.pt-BR.md`, `RELEASE.pt-BR.md` e os guias adaptados em `docs/pt-BR/`. Os índices [inglês](docs/README.md) e [brasileiro](docs/pt-BR/README.md) relacionam as duas edições. Automação, imagens e arquivos estruturados são compartilhados.

## 28/10/2026 · Evidências da plataforma e automação

A base reúne treze módulos, fases Ansible, helpers operacionais, integração EKS/ECR, diagnóstico Proxmox/GPU/kernel e console DRAC5 isolado. Inclui snapshot genérico do hardware, inventário com cinco control planes e oito workers, comparação de recursos somente para leitura, posicionamento de VMs e duas capturas Grafana originais com manifesto de integridade.

O [relatório de validação](docs/pt-BR/package-validation.md) registra testes offline, verificações de sintaxe dos 15 playbooks, renderização de 16 templates e sintaxe dos 17 helpers shell e do entrypoint DRAC5. São resultados da revisão original, com escopo separado da validação funcional de uma implantação.

A revisão de 17 vistas de infraestrutura estabelece dois hosts Kubernetes, dois hipervisores exclusivamente de infraestrutura e divisão de control planes em três/dois. Workers somam 64 CPU e 124,1 GiB alocáveis no painel correspondente. Consulte o [registro da plataforma](docs/pt-BR/den-case-study.md) e os [experimentos](docs/pt-BR/den-validations-experiments.md).

## Configuração e responsabilidade

Siga o [guia de automação](docs/pt-BR/automation.md), fornecendo inventário, versões, imagens e credenciais privados. Defina um responsável pela reconciliação de cada recurso ao transferir configuração de Ansible para Argo. Fontes brutas, aliases privados e segredos ficam fora da distribuição.

## Gerar o pacote

Na raiz, escolha um nome ainda inexistente:

```bash
mkdir -p dist
bash scripts/package-release.sh dist/forest-reforge-2026-10-30.tar.gz
shasum -a 256 dist/forest-reforge-2026-10-30.tar.gz > dist/forest-reforge-2026-10-30.tar.gz.sha256
tar -tzf dist/forest-reforge-2026-10-30.tar.gz
```

O empacotador inclui os documentos dos dois idiomas, `LICENSE`, assets públicos, guias, módulos, exemplos, scripts, automação e testes. Exclui `reference/`, `local/`, credenciais e estado privado de execução, arquivos da IDE, ambientes virtuais e bytecode. Não sobrescreve arquivos existentes. Revise os membros e o checksum antes de publicar.

## Licença

Preserve a [GNU GPL v3.0](LICENSE) e os avisos de terceiros na distribuição.
