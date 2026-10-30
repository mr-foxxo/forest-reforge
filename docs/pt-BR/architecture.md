# Arquitetura e evidências

[English (default)](../architecture.md) | [Português (Brasil)](architecture.md) | [Índice](README.md)

## Limites de responsabilidade

Separe a infraestrutura física, o gerenciamento, as aplicações e o controle de nuvem. Trocar uma GPU ou reconstruir Kubernetes deve preservar DNS, acesso ao roteador e recuperação.

| Camada | Responsabilidade | Limite |
|---|---|---|
| Rack | Energia, refrigeração, sustentação e cabos | Dependências físicas documentadas |
| OpenWrt | Zonas roteadas, filtros e VPN | Sem pontes amplas entre zonas de confiança |
| DNS independente | Registros internos e resolução | Funciona sem o cluster |
| Proxmox | Ciclo de vida de VMs, dispositivos e discos | Aplicações ficam nos convidados |
| Kubernetes | Serviços e estado explicitamente escolhido | Backups e credenciais têm cópias independentes |
| Cilium/Gateway API | Rede, políticas e rotas de aplicação | Gerenciamento de infraestrutura permanece privado |
| Cloudflare | Acesso publicado e transporte de borda | Aplicação verifica sua própria autorização |
| GitHub | Membros, código e entrega | Associação não concede cluster-admin |
| AWS | Contas, regiões e EKS | Fronteiras próprias de rede e identidade |

## Classificação das evidências

- **Relatado pela fonte:** documentação ou conversa informa execução; sem verificação ao vivo nesta revisão.
- **Observado em captura:** campo ou estado visível no instante da captura; data de revisão não é necessariamente a data da imagem.
- **Proposto:** desenho ou procedimento genérico para reprodução.
- **Experimental:** exige qualificação e pode não ter suporte do fabricante.
- **Desconhecido:** material insuficiente para concluir.

Uma afirmação de implantação não comprova failover, restauração ou isolamento. A revisão de 28/10/2026 reúne sete imagens iniciais e dez complementares; apenas dois originais limpos são [públicos](assets/README.md). Fontes e aliases privados permanecem fora do pacote.

## Topologia e falhas

O exemplo de instalação nova coloca nós no segmento Servers, permitindo anunciar o VIP no mesmo domínio L2. Nós apenas no segmento VMs não respondem ARP no segmento Servers: mova o VIP ou projete anúncio roteado explicitamente. Não una zonas para contornar isso.

O Den observado tem cinco control planes em divisão três/dois entre hv01/hv02. Com cinco votantes stacked-etcd, perder hv01 deixa dois, sem maioria; perder hv02 deixa três. Verifique os membros reais antes de testar. Os outros dois hipervisores não contam como domínios Kubernetes. Três VMs no mesmo host, duas fontes na mesma PDU e duas réplicas no mesmo host compartilham falhas físicas. LocalPV não é armazenamento distribuído.

## Reconciliação e exemplos

Ansible prepara a base e segredos de bootstrap; Argo reconcilia aplicações transferidas. Escolha um responsável por objeto, inclusive Namespace, Secret, Gateway e Application. Configuração AWS/Cloudflare tem controle separado.

Use `example.net`, `example.org`, `example-org` e IDs AWS fictícios `111122223333`/`444455556666`. Consulte as [decisões](decisions.md) e os [testes de aceitação](acceptance.md).
