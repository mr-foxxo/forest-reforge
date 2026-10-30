# Automação do Forest Reforge

[English (default)](../automation.md) | [Português (Brasil)](automation.md) | [Índice](README.md)

O [inventário revisado em 30/10/2026](den-inventory.md) complementa o [exemplo do tamanho da Toca](../../automation/ansible/inventory.observed.example.yml) com `reforge_inventory_vcpus`, `reforge_inventory_ram_value` e a nota opcional `reforge_inventory_gpu`. `reforge_inventory_ram_unit` continua vazio, pois a fonte não informa unidade. Esses campos são descritivos: não redimensionam convidados, configuram GPUs nem substituem medições anteriores de capacidade/alocável no perfil do checker.

A implementação portátil usa Ansible, configurações de serviços e helpers derivados das fontes do projeto. É uma **implementação proposta com validação offline**, sem certificação de reprodução integral da plataforma. Nenhuma configuração é carregada de `reference/`. Consulte o [mapa das fontes](automation-source-map.md).

Esta edição apresenta o fluxo de trabalho. Antes de aplicar fases, consulte também os contratos detalhados de cada serviço no [guia canônico](../automation.md); as configurações executáveis são compartilhadas pelos dois idiomas.

## Ambiente existente: primeiro inspecione

O [snapshot da Toca](den-case-study.md) registra cinco control planes/oito workers e dois hosts Kubernetes. hv03/hv04 são infraestrutura; não devem entrar em `canopy`. O campo `reforge_hypervisor` informa posicionamento, sem criar ou migrar VMs. A versão kubelet observada não define automaticamente API server, containerd, driver ou chart.

No controlador preparado, faça comparação somente para leitura:

```bash
python scripts/cluster-resources.py --context YOUR_CONTEXT --expect examples/observed-platform.json
```

Não execute `roots`, `canopy` ou `main.yml` apenas para conferir screenshots: essas fases gerenciam sistema, runtime e bootstrap.

## Preparar controlador e entradas privadas

Execute os comandos na raiz. O guia original requer Linux/macOS com Bash, Python 3.11+, Helm 3, kubectl e SSH; o projeto declara Python 3.12+ em `pyproject.toml`. O pacote usa rsync/tar; helpers AWS usam AWS CLI v2/jq. Os nós são convidados Debian/Ubuntu com systemd, Python e sudo, Kubernetes 1.31+ para kubeadm v1beta4. A role de runtime suporta containerd 1.x; 2.x requer qualificação separada.

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r automation/controller-requirements.txt
ansible-galaxy collection install -r automation/ansible/requirements.yml
mkdir -m 700 -p local
cp automation/ansible/inventory.example.yml local/inventory.yml
cp automation/ansible/site.example.yml local/site.yml
cp automation/ansible/secrets.example.yml local/secrets.yml
```

Escolha o inventário observado como alternativa ao inicial. Edite os arquivos privados, execute `ansible-vault encrypt local/secrets.yml` e só marque `reforge_inventory_reviewed: true` após revisar. Preserve verificação de host SSH. Não publique saídas, use `--diff` em segredos ou guarde senha do Vault no repositório.

| Contrato | Entradas obrigatórias |
|---|---|
| Rede | IPs/NICs, DNS independente, VIPs reservados, CIDRs sem sobreposição; nome da API resolvido por todos os nós |
| Versões | Kubernetes upstream e pacote exato compatíveis, containerd, digests pause/kube-vip, charts, URL e SHA-256 independente dos CRDs |
| Recuperação | Console, backup externo, confiança SSH e etcdctl/etcdutl compatíveis |
| Criptografia | Chave gerada uma vez com `openssl rand -base64 32`, guardada no Vault e em backup independente |
| Contexto | `reforge_kubeconfig` absoluto e `reforge_kube_context` explícito |
| Serviços | Zona DNS real, token restrito, email ACME, StorageClass, URL GitOps e SHA completo |

Não regenere a chave a cada execução. A role rejeita chave existente diferente; rotação exige procedimento próprio com chaves antiga/nova, atualização dos API servers, regravação e validação dos Secrets.

## Executar por fases

```bash
bash scripts/reforge.sh plan roots local/inventory.yml local/site.yml
bash scripts/reforge.sh apply roots local/inventory.yml local/site.yml
bash scripts/reforge.sh apply canopy local/inventory.yml local/site.yml local/secrets.yml
```

`plan` é check mode parcial: pode contatar hosts e executar inspeções. Não simula integralmente pacotes ou CRDs ausentes. Valide uma fase antes de continuar.

| Fase | Responsabilidade | Verificação |
|---|---|---|
| `names` | DNS independente opcional, sem DHCP | DNS TCP/UDP e recuperação da configuração |
| `roots` | Swap, módulos/sysctls, pacotes fixados e cgroups | Runtime funcional; snapshot para reversão |
| `canopy` | kubeadm criptografado, API VIP e joins sequenciais | API; investigar falhas sem resetar membros existentes |
| `paths` | CRDs, Cilium, pool e anúncio L2 | Ready, saúde Cilium, ARP e conectividade |
| `vault` | LocalPV e classe Retain não padrão | PVC com consumidor e restauração |
| `gatehouse` | cert-manager, DNS-01 e Gateway HTTPS | ACME staging antes de produção |
| `trails` | Argo, projetos, aplicação raiz e Dex opcional | Login permitido/rejeitado e destinos |
| `lookout` | Monitoramento persistente, ESO/logs opcionais | PVCs, targets e entrega de alertas |
| `baseline` | PSA restrito, negação padrão e DNS | Políticas específicas e rejeições |
| `backstage` | Configuração, banco, aplicação e rota | Recuperação do banco, catálogo e permissões |
| `edge` | Tunnel e dois conectores fixos | Access validado, SNI/TLS e rejeição externa |
| `backup` | Snapshot/timer por control plane | Cópia externa e restauração isolada |
| `burrows` | IOMMU no bootloader selecionado | Console, boot posterior e grupos |
| `embers` | Headers, ferramentas e drivers fixados opcionais | Módulos, assinaturas e perfis |

`main.yml` reúne fases do cluster, excluindo DNS independente, hipervisores, Backstage e edge. Após `canopy`, obtenha `/etc/kubernetes/admin.conf` por canal seguro, modo 0600, valide identidade da API e configure seu caminho absoluto. Expansão usa inventário completo, preservando o control plane de origem; joins existentes são ignorados e tokens curtos revogados após uso.

Cilium começa com VXLAN. Native routing/WireGuard exigem validação própria. Rollback Helm não desfaz CRDs ou dados. LocalPV LVM requer volume group existente e lista explícita de nós; a role não formata discos nem cria VG.

## Identidade e aplicações

Use OAuth separado para Access, Argo/Dex e Backstage. Preserve recuperação local Argo até testar SSO e falha do provedor. Argo e Grafana permanecem privados; a HTTPRoute fornecida é para Backstage. A aplicação raiz pertence a administradores; aplicações comuns têm destinos e recursos limitados.

Forneça imagem Backstage imutável com auth GitHub, catálogo da organização, PostgreSQL, endpoints de saúde e política de autorização implementada. O contrato do launcher usa `node packages/backend`, UID 1000 e porta 7007. `permission.enabled` sozinho não implementa a política. Prepare banco, backups, TLS verificado e CIDR real; para ECR, configure pull Secret renovável.

Antes de `edge`, crie Tunnel e Access restrito, teste rejeição e marque `reforge_access_policy_verified: true`. Publique Backstage apenas. Configure origem HTTPS no Gateway, `originServerName` e `httpHostHeader` com hostname correto, certificado de produção e verificação TLS ativa. Anti-afinidade dos dois conectores requer dois workers.

Transfira recursos para Argo por comparação de estado, sincronização inicial sem pruning destrutivo e suspensão da role Ansible correspondente. Defina um responsável por recurso. ESO não escolhe backend; Loki/Alloy exigem versões e valores privados de armazenamento/retenção. O Loki do exemplo é interno e sem autenticação; não o publique.

## AWS, GPU e console

Helpers AWS exigem perfil nomeado, contexto explícito e identidade renovável nos componentes Argo. SSO da estação e anotação IRSA isolada não autenticam pods locais. Autorize AssumeRole tanto na origem quanto na confiança do destino; limite EKS e AppProject por namespace. ECR expira em 12 horas: adapte timer/serviço, monitore renovação e configure `imagePullSecrets`.

`proxmox-vm.sh` importa imagem com checksum em VM nova parada e rejeita VMID existente. `gpu-diagnose.sh` inspeciona BDF; `kernel-gate.sh` verifica artefatos sem selecionar boot; `gpu-driver.sh` verifica/extrai instalador confiável, executando código do fornecedor. Sem reboot automático, patch inventado ou bypass de licença. Siga o [runbook P4](r710-p4-vgpu-runbook.md).

O [console DRAC5](drac5-apple-silicon-runbook.md) usa JDK8 i386, JARs privados, JNLP recente e VNC local com senha. Não é login automático demonstrado nem substitui a validação da sessão real.

## Recuperação e publicação

Proteja backups, PKI e chave de criptografia; confirme cópia externa, checksums e restauração isolada antes de depender do timer. Execute a [validação do pacote](package-validation.md) e os [testes funcionais](acceptance.md). O empacotador distribui documentação e automação públicas, excluindo fontes e entradas privadas.
