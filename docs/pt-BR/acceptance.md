# Aceitação, reversão e evidências

[English (default)](../acceptance.md) | [Português (Brasil)](acceptance.md) | [Índice](README.md)

O [registro do Den](den-case-study.md) comprova campos observados de hardware, pools ONLINE e 13 nós Ready. As [validações complementares](den-validations-experiments.md) acrescentam posicionamento de VMs e métricas. Failover, restauração, rejeição de acesso e execução CUDA/modelos exigem resultados funcionais próprios.

| Área | Teste positivo | Teste negativo ou de falha | Evidência |
|---|---|---|---|
| Física | Temperatura e potência estáveis | Resposta à perda de refrigeração/desligamento controlado | Medições |
| Memória | População final sem erros repetidos | Reproduzir módulo/slot suspeito | Matriz de testes |
| Roteador | Paws administra | wg-admin bloqueado em todos os IPs locais | Contadores e resultado do cliente |
| DNS | Serviços concedidos ao paws | Sem acesso Infra não autorizado | Matriz de conexões |
| Proxmox | Restaurar VM descartável | Inicializar kernel preservado | Log de restauração |
| GPU | Executar workload real | Registrar combinação incompatível | Versões completas |
| Kubernetes | API, DNS e tráfego entre nós | Failover de um componente por vez | Condições e tempos |
| Gateway | TLS pela LAN/VPN | Host incorreto não roteado | HTTP e TLS |
| Armazenamento | Dado sentinela persiste | Restauração independente | Checksum ou consulta |
| Identidade | Usuário autorizado entra | Externo/removido é negado | Resultado sem dados sensíveis |
| GitOps | Commit sincroniza recurso permitido | Destino errado rejeitado | Evento Argo e RBAC |
| AWS | STS, EKS e implantação limitada | Namespace proibido negado | Principal e resultado |
| Recuperação | Restauração isolada completa | Portal/IdP indisponível | RPO/RTO medidos |

## Sequência

Comece com leitura, passe para recursos descartáveis e reserve testes disruptivos para uma janela de manutenção. Registre o estado inicial e quem reconcilia cada recurso. Antes de excluir `reforge-smoke`, confirme que só contém dados descartáveis. Pods Running não demonstram acesso externo, autorização ou backup restaurável.

## Registro de rollback

Registre versões/configuração anteriores, inicialização conhecida, workloads afetados, indisponibilidade prevista, localização do backup, reversão exata e aceitação após retorno. Guarde o registro fora do sistema alterado.

## Limites da validação do pacote

Links, sintaxe, templates e exclusões são verificações do repositório. `cluster-resources.py --context YOUR_CONTEXT --expect examples/observed-platform.json` compara Nodes e capacidade dos workers; não testa Pods, métricas, serviços, posicionamento ou recuperação. Uma divergência pode ser uma atualização intencional. Declare validação local somente para a combinação e os testes registrados no [modelo de stack](examples/validated-stack.md).
