# 11 · Skybridge — AWS e entrega híbrida

[English (default)](../../../modules/11-skybridge-aws.md) | [Português (Brasil)](11-skybridge-aws.md) | [Índice](../README.md)

As fontes identificam Forest e FoxByte, dev ativo e produção dormente, sem staging demonstrado. Nome de cluster não prova conta por ambiente. Registre conta, região, role e responsável; IDs públicos são fictícios.

## Contas e rede

Inventarie Organizations/OUs/contas antes de criar recursos. Separe administração organizacional de deploy, proteja recuperação root/MFA, use acesso humano temporário, budgets, auditoria e tags. Registre custos e teardown de EKS, NAT, VPN, LB, logs e armazenamento.

Escolha CIDRs não sobrepostos e rotas de ida/volta. Verifique túneis VPN, DNS, security groups, firewall, MTU e modo de endpoint EKS. Endpoint privado requer resolução/rota do Den; público restrito requer origem permitida estável.

**VPC peering não oferece trânsito.** Não presuma caminho Den → VGW na VPC A → peering → VPC B. Projete conectividade suportada por destino e resolvers explicitamente.

## Cadeia de autenticação Argo

Identidade base no pod local → STS AssumeRole → token EKS → Access Entry → autorização Kubernetes. SSO da estação, EKS Pod Identity e anotação IRSA isolada não resolvem identidade on-prem. Forneça mecanismo renovável revisado nos componentes que precisam dele e confirme `argocd-k8s-auth` na imagem.

1. Autorize origem a assumir ARN exato e confiança do destino para essa origem.
2. Habilite modo EKS compatível com Access Entries e entrada STANDARD da role.
3. Limite política/RBAC por namespace, sem permissões globais desnecessárias.
4. Descubra endpoint/CA pelo perfil designado, distinto da identidade runtime.
5. Crie Secret Argo privado com exec auth compatível, região, cluster e role.
6. Restrinja AppProject e teste workload descartável mais namespace proibido.

Use [eks-access.sh](../../../scripts/eks-access.sh), [eks-register.sh](../../../scripts/eks-register.sh) e [ecr-refresh.sh](../../../scripts/ecr-refresh.sh) primeiro com `plan`, conforme [automação](../automation.md). A política de edição por namespace inclui Secrets de workload e não remove permissões amplas já existentes.

## Diagnóstico e imagens

`SignatureDoesNotMatch`: par de chaves, relógio e session token. `AccessDenied` em AssumeRole: políticas da origem e confiança. STS funciona/EKS nega: Access Entry/RBAC. Timeout: DNS/rota/endpoint antes de IAM. Teste com a identidade do componente que falha, sem publicar respostas STS completas.

Separe pull ECR de acesso AWS pela aplicação. Tokens ECR duram 12 horas; renove Secret local ao namespace, monitore timer e configure `imagePullSecrets`. Identidades de workloads devem ser limitadas. OIDC GitHub Actions é opção futura com trust por repo/ref/environment, sem credenciais para PR não confiável. Produção não é ativada automaticamente.
