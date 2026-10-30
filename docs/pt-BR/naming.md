# Nomes do projeto e dos recursos

[English (default)](../naming.md) | [Português (Brasil)](naming.md) | [Índice](README.md)

**Forest Reforge** representa o reaproveitamento de hardware por meio de engenharia. O repositório usa `forest-reforge`; não há declaração de exclusividade ou marca registrada. Use nomes por função nos exemplos e aliases amigáveis somente nas descrições privadas.

| Recurso | Padrão/exemplo |
|---|---|
| Local físico | `den` |
| Roteador e DNS | `gw01`, `dns01` |
| Hipervisor e NAS | `hv01`, `hv02`, `nas01` |
| OOB | `mgmt.hv01.den.int.example.net` |
| Nó Kubernetes | `core-cp01`, `core-wk01` |
| Aplicação | `backstage.den.int.example.net` |
| API | `api.k8s.den.int.example.net` |
| Cluster AWS | `forest-dev`, `foxbyte-dev` |
| Role AWS | `argocd-forest-dev-deployer` |
| Aplicação GitOps | `den-platform` |
| Tags | `Project`, `Owner`, `Environment`, `Site`, `ManagedBy` |

Mantenha hostname curto do sistema alinhado ao inventário e FQDN no DNS/configuração hosts. Decida nomes antes do kubeadm; renomear membro já integrado requer operação de ciclo de vida.

No [snapshot](../../examples/observed-platform.json), hv01/hv02 hospedam Kubernetes; hv03/hv04 são infraestrutura; nas01 fornece armazenamento independente. Esses aliases não criam nós adicionais nem obrigam renomear equipamentos existentes. A relação privada entre alias e máquina fica em `local/den-evidence/`.

O wildcard `*.den.int.example.net` cobre `grafana.den.int.example.net`, mas não `mgmt.hv01.den.int.example.net` nem `api.k8s.den.int.example.net`. Use certificados/SANs específicos.

Os nomes de arquivo e recursos permanecem iguais nos dois idiomas. Traduza o texto explicativo; preserve identificadores usados pela automação.
