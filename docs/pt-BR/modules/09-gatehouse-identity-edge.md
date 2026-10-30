# 09 · Gatehouse — identidade e acesso externo

[English (default)](../../../modules/09-gatehouse-identity-edge.md) | [Português (Brasil)](09-gatehouse-identity-edge.md) | [Índice](../README.md)

A organização GitHub fornece membros; Cloudflare Access restringe a aplicação publicada; Backstage faz seu próprio login GitHub e resolve usuários no catálogo. Cada camada precisa de testes próprios. Argo, Grafana, Hubble, API, Proxmox e BMC ficam privados. Inicialmente publique **somente Backstage**.

## Configuração

1. Defina organização, equipes e política de membros; teste membro e não membro.
2. Configure OAuth/IdP GitHub no Access com callback exato, guardando segredo fora do Git.
3. Crie aplicação Access no hostname antes da rota pública, sem bypass amplo.
4. Crie Tunnel gerenciado remotamente e armazene token na autoridade de segredos.
5. Aponte hostname Backstage à origem HTTPS Gateway, definindo SNI e Host HTTP iguais ao nome esperado. Mantenha verificação do certificado e confira cobertura de TLS da borda separadamente.
6. Configure conector com imagem fixada, Secret, métricas/readiness em endpoint estável e duas réplicas distribuídas.

A política de saída deve permitir DNS, destinos Cloudflare necessários/porta 7844 TCP/UDP e Gateway TCP 443, acrescentando só dependências justificadas. Evite definições duplicadas em caminhos Argo recursivos. Token não entra em argumentos impressos nem no Git.

## Identidade da aplicação

Backstage requer provider GitHub, ingestão organizacional, resolução por ID imutável e política real de permissões; `userIdMatchingUserEntityAnnotation` depende de entidade importada correspondente. Mantenha guest desabilitado. Cabeçalhos de identidade só são confiáveis após validação de issuer/audience ou componente configurado para isso.

Keycloak/OIDC amplo é opção futura com ADR próprio, MFA, mapeamentos e recuperação local. GitHub OAuth não se torna automaticamente IdP OIDC universal.

## Aceitação

Teste acesso externo de membro, rejeição de externo/removido após refresh/expiração, permissões de escrita e acesso privado ainda autenticado. Confira ausência de hostnames/DNAT para infraestrutura. Se Tunnel conecta mas pod reinicia, investigue probe/args e objetos duplicados antes de trocar token. QUIC buffer warning sozinho não prova falha de autenticação. Veja [automação](../automation.md).
