# Mapa das fontes para a automação

[English (default)](../automation-source-map.md) | [Português (Brasil)](automation-source-map.md) | [Índice](README.md)

A implementação usa variáveis `reforge_*`, hosts por função, domínios e endereços de documentação e contas fictícias. Nenhum inventário, Vault, artefato ou identificador privado é importado. As fontes permanecem locais, fora do pacote.

| Fontes/área | Implementação portátil | Limite |
|---|---|---|
| Preparação e expansão | Roots/Canopy, pacotes fixados, kubeadm v1beta4, criptografia, VIP, joins sequenciais e tokens curtos | Sem reset, Calico antigo ou topologia física inventada |
| Cilium/Gateway | CRDs antes do CNI, interfaces/pool explícitos, anúncio restrito ao Gateway | VXLAN inicial; roteamento nativo/criptografia separados |
| DNS/TLS | DNS independente opcional, Cloudflare DNS-01, staging e Gateway | Sem migração automática de autoridade ou chave global |
| Storage/segredos | LocalPV Retain, PSA, default deny, Secrets protegidos e ESO opcional | Sem apagar discos, inventar backend ou declarar HA LocalPV |
| GitOps | Commit explícito, projetos limitados, Argo privado e Dex opcional | Raiz administrativa separada de workloads |
| Identidade/Backstage | OAuth separado, catálogo GitHub e banco TLS | Sem bypass guest ou Access como autorização da aplicação |
| Edge | Backstage primeiro, duas réplicas fixas, readiness e egress limitado | Sem infraestrutura publicada, DNAT WAN ou TLS desativado |
| AWS | Perfis nomeados, Access Entries, registro Argo, IAM e renovação ECR | Identidade de runtime fornecida pelo operador; produção dormente |
| Operação | Diagnóstico por camada, métricas, logs explícitos, snapshot etcd e timer | Sem limpeza ampla ou restauração automática não testada |
| R710/P4 | BDF explícito, verificação de kernel, extração com checksum e perfil nativo | Sem patch fabricado ou bypass de licença |
| DRAC5 | linux/386, JDK/JNI, JNLP privado, VNC local com senha | Fetcher histórico não fornecido nem validado |
| IA | Build por commit, alvos CUDA 52/61/70 e opções CPU legadas | Build não equivale a benchmark ou modelo validado |

O [registro de decisões](decisions.md) resolve conflitos; o [original inglês](../automation-source-map.md) mantém a correspondência detalhada das notas numeradas. Não misture playbooks antigos e novos sobre os mesmos objetos.

As 17 vistas da Toca informam [plataforma](den-case-study.md), [experimentos](den-validations-experiments.md) e [snapshot](../../examples/observed-platform.json). Imagens públicas têm [manifesto](../../assets/evidence.json). O [inventário observado](../../automation/ansible/inventory.observed.example.yml) registra posicionamento como metadado; o checker de Nodes não modifica o cluster. Resultados funcionais continuam separados das observações.

O inventário do operador revisado em 30/10/2026 acrescenta plataformas, vCPU/RAM declaradas por VM, associação V100 e entradas independentes de rede/OOB/gerenciamento. O [guia de inventário](den-inventory.md) publica uma derivação genérica nos dois idiomas. Unidade RAM e campos vazios de gerenciamento continuam não especificados; endereços, aliases e hash da fonte permanecem locais. Medições dos Nodes não são substituídas pelas declarações.
