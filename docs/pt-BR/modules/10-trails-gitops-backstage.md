# 10 · Trails — GitOps e portal do desenvolvedor

[English (default)](../../../modules/10-trails-gitops-backstage.md) | [Português (Brasil)](10-trails-gitops-backstage.md) | [Índice](../README.md)

Separe este repositório público, implementação privada de infraestrutura, repositório GitOps e código/build da aplicação Backstage. Defina responsável por cada objeto. Ansible cria bootstrap; Argo controla aplicações filhas e recursos transferidos.

## Argo CD

1. Instale chart fixado após rede, persistência e TLS.
2. Configure URL privada, autenticação e recuperação local. Dex/GitHub só após revisar grupos e permissões.
3. Entregue credenciais de repositório com acesso mínimo, fora do Git.
4. Crie aplicação raiz em commit explícito, com AppProjects e filhos limitados; revise renderização antes de pruning automático.
5. Restrinja fontes, destinos, namespaces e recursos de cluster em complemento ao RBAC Kubernetes.
6. Sincronize aplicação descartável e prove rejeição de namespace/cluster incorretos.

Caminhos lógicos sugeridos: `bootstrap/`, `clusters/den/platform/`, `clusters/den/applications/`, `clusters/forest-dev/` e `clusters/foxbyte-dev/`. Produção fica dormente, sem filhos ativos por padrão. São convenções, não uma árvore completa fornecida aqui.

## Backstage

Construa app separado com Node/gerenciador/lockfile registrados, autenticação GitHub, catálogo organizacional e plugins necessários. Alinhe base URL app/backend, CORS, callback e HTTPRoute. Prepare PostgreSQL, backup/restauração, segredos e imagem imutável com digest. O contrato de referência usa porta 7007; teste endpoints de saúde da imagem construída.

Transfira Deployment, Service, ConfigMap, HTTPRoute, PDB e políticas por comparação de estado, suspendendo a role Ansible correspondente. Opção de banco interno inclui StatefulSet/Service/PVC dedicados e recuperação obrigatória. Verifique migrações, catálogo, login e autorização; readiness deve testar aplicação local, sem desafio Access.

ECR expira em 12 horas. Configure renovação monitorada de pull Secret e teste novo pull; pod em execução não comprova pulls futuros. Preserve digest anterior para rollback.

## Caminho do desenvolvedor

Importe usuários/equipes e resolva `spec.owner` para Group. Plugin Kubernetes usa ServiceAccount de leitura limitada, sem cluster-admin. Fluxo futuro: escolher template/proprietário → criar repo → CI publica imagem imutável → propor mudança GitOps → revisão autorizada → Argo aplica → catálogo mostra observabilidade.

Aceitação: usuário correto, ação proibida negada, digest correspondente, banco persistente e rollback funcional. Os [painéis Argo](../den-validations-experiments.md) demonstram execução dos componentes, sem substituir esses testes. Veja [automação](../automation.md).
