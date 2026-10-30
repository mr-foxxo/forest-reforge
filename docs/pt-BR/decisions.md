# Registro de decisões

[English (default)](../decisions.md) | [Português (Brasil)](decisions.md) | [Índice](README.md)

Estas decisões orientam os exemplos genéricos. Documentos históricos podem conter alternativas superadas; reconcilie o ambiente real antes de automatizar.

| Tema | Decisão |
|---|---|
| Nomes | `hv01/hv02` e `core-*`; aliases privados ficam no histórico |
| Rede dos nós | Novas instalações usam Servers; descubra endereços do ambiente existente |
| VIPs | API `172.16.3.30`; Gateway `172.16.3.200`, com anunciadores no mesmo L2 |
| CNI | Cilium com substituição de kube-proxy; caminho Calico antigo não é o padrão |
| Escala | Exemplo inicial menor separado do observado com cinco control planes/oito workers |
| Hosts | Só hv01/hv02 hospedam Kubernetes; hv03/hv04 são infraestrutura |
| Posicionamento | hv01: cp01–03/wk01–04; hv02: cp04–05/wk05–08; quórum físico assimétrico |
| RAM | Usar 125,87/62,65 GiB exibidos nos hosts Kubernetes; sem inferir DIMMs |
| Inventário atual | Plataformas T310/T410 somente de infraestrutura; 14 vCPU nos control planes, 64 nos workers e nota V100 em core-wk05, com fonte de inventário |
| RAM declarada/medida | A fonte soma 152 para workers sem informar unidade; painel anterior mostra 124,9/124,1 GiB capacity/allocatable. Confirmar unidade/configuração atual, sem substituir medições por declarações |
| Recursos | 64 CPU, 124,1 GiB alocáveis e 116 pods são dados restritos a workers |
| NAS | Dois pools ONLINE de um disco; exportação, redundância e restauração não demonstradas |
| DNS/TLS | Cloudflare é o caminho posterior à migração; Route 53 é alternativa |
| Publicação | Somente Backstage inicialmente |
| Administração do roteador | Paws; wg-admin negado em todos os endereços locais |
| Acesso paws ao DNS | Todos os serviços de dns01, sem liberar toda a zona Infra |
| Identidade | Organização GitHub, Access e autenticação Backstage; Keycloak opcional futuro |
| Argo | Recuperação local mantida; Dex optativo após validação |
| Banco | PostgreSQL em VM ou opção LocalPV dedicada; documentar risco e recuperação |
| Registry | ECR no histórico operacional; GHCR como alternativa explícita |
| Imagens | Digest ou versão imutável; sem substituir silenciosamente por `latest` |
| AWS | Dev ativo; produção dormente; sem staging demonstrado |
| Contas AWS | Escopos Forest/FoxByte; não inventar OUs, contas ou IDs implantados |
| ESO/logs | Backend, retenção e versões precisam de decisões explícitas |
| ExternalDNS | Registros manuais até transferência deliberada de responsabilidade |
| P4 | Limite oficial branch 16; marco de host 16.14/535.309.01 relatado, convidado pendente |
| V100/M40 | V100 branch 19 exige combinação qualificada; M40 sem vGPU oficial |
| DRAC5 | JNI i386 e opção de teclado confirmados; login automático não demonstrado |
| Idiomas | Inglês canônico; alternativas brasileiras adaptadas com links equivalentes |

Atividade de node-feature-discovery não comprova alocação GPU, licença ou execução CUDA. Resets históricos que limpam firewall e armazenamento não pertencem ao fluxo normal. Limpeza deve atingir apenas recursos de teste identificados.

## Decisões pendentes

Medidas do rack, endereçamento real, identidade das GPUs, qualificação de cada combinação, backend de segredos, RPO/RTO, localização durável dos dados, necessidade de federação, rotas AWS e critérios de ativação da produção. Consulte o [registro inglês completo](../decisions.md) para os conflitos de origem de cada escolha.
