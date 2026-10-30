# Solução de problemas por camada

[English (default)](../troubleshooting.md) | [Português (Brasil)](troubleshooting.md) | [Índice](README.md)

Comece por leitura e evidência da primeira camada que falha. Para inventário/capacidade, use `python scripts/cluster-resources.py --context YOUR_CONTEXT --expect examples/observed-platform.json` no controlador preparado. Diferença de snapshot pode ser atualização deliberada.

| Sintoma | Primeiro diagnóstico | Evite |
|---|---|---|
| Erros de RAM por população | Matriz módulo/slot/canal e BIOS | Condenar todos os DIMMs |
| GPU ausente no PCI | Riser, energia, firmware e identidade | Trocar repetidamente drivers |
| Compilação do driver falha | Kernel, headers e primeiro erro | Culpar apenas taint |
| Host funciona, VM falha | Binding VFIO/perfil e logs convidados | Licenciar host como convidado |
| CUDA visível, modelo falha | CC, arquiteturas do binário e operador | Tratar `nvidia-smi` como inferência validada |
| `Illegal instruction` | Flags CPU e compilação | Culpar GPU automaticamente |
| VIP sem resposta | Pool, lease, ARP e interface no mesmo L2 | Instalar outro controlador LB |
| LAN funciona, VPN falha | Rotas de ida/volta, firewall e MTU | Reconstruir cluster |
| TLS inválido | Cadeia, SNI, hostname e confiança | Manter verificação desativada |
| DNS-01 travado | Autoridade pública e destino do challenge | Abrir HTTP na WAN |
| Tunnel conecta, pod reinicia | Args, probe `/ready`, objetos duplicados | Rotacionar token sem diagnóstico |
| Login sem usuário Backstage | Catálogo, annotation e sync da organização | Habilitar guest |
| Permissões erradas | Grupos e política da aplicação | Confundir Access com administrador |
| Helper Argo sai com 20 | STS no contexto de execução | Conceder AdministratorAccess |
| STS funciona, EKS nega | Access Entry/RBAC/namespace | Alterar rotas sem motivo |
| Pull posterior falha | Idade/escopo do token ECR | Repetir `latest` |
| PVC não muda de nó | Afinidade LocalPV e localização dos dados | Excluir PVC |

## Incidente de VIP Cilium

1. Confirme Service LoadBalancer e IP ingress esperado.
2. Confira condições do pool, seletores, reserva e unicidade do endereço.
3. Inspecione configuração ativa e elegibilidade da política L2; valores Helm podem divergir do runtime.
4. Confira leases/anunciador e capture ARP na interface e segmento corretos.
5. Nós em `172.16.4.0/24` não anunciam diretamente VIP `172.16.3.200` em outro L2; resolva a topologia.
6. Teste TCP/TLS no mesmo L2, depois LAN roteada e VPN; compare contadores e rotas no primeiro salto que falha.
7. Com rede funcional, investigue listeners Gateway, HTTPRoutes e backends.

Compartilhe versões e reproduções mínimas sem kubeconfigs, Secrets, tokens Tunnel/JNLP, seriais ou endpoints WAN privados. Registre o que mudou e a combinação anterior que ainda funciona.
