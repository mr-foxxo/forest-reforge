# 07 · Canopy — Kubernetes

[English (default)](../../../modules/07-canopy-kubernetes.md) | [Português (Brasil)](07-canopy-kubernetes.md) | [Índice](../README.md)

Fases `roots`, `canopy`, `paths` e depois serviços configuram pacotes/runtime, bootstrap e rede. Consulte [automação](../automation.md) e [arquitetura](../architecture.md).

## Ordem de implantação

1. Defina inventário, DNS/API VIP, CIDRs sem conflito e versões exatas de Kubernetes/runtime/imagens.
2. Prepare convidados dedicados com systemd, DNS, hora, rede e instruções CPU adequadas. A implementação suporta containerd 1.x.
3. Inicialize primeiro control plane com kubeadm v1beta4, criptografia de Secrets e endpoint canônico VIP. Preserve chave, PKI e configuração em backup independente.
4. Recupere `admin.conf` por canal seguro, modo 0600, e configure caminho/contexto explícitos no controlador.
5. Integre demais nós sequencialmente com tokens curtos, preservando o control plane de origem no inventário.
6. Instale CRDs Gateway API verificados antes do Cilium. O exemplo usa substituição de kube-proxy e VXLAN; outras opções exigem qualificação.
7. Configure pool LB e política L2 com interfaces/seletores explícitos; anunciadores precisam alcançar o L2 real do VIP.
8. Configure Gateway HTTPS, certificados e HTTPRoute de aplicação após validar rede.

API VIP e Gateway VIP são recursos distintos. Não instale outro controlador de LoadBalancer apenas para mascarar falha de anúncio. CRDs e dados persistentes não são desfeitos automaticamente por rollback Helm.

## Aceitação

Verifique Ready e condições, DNS de Pods, comunicação entre nós, políticas permitidas/negadas, saúde Cilium, API pelo VIP e tráfego Gateway desde LAN/VPN. Teste hostname incorreto e autorização. Pods Running não bastam.

O [Den observado](../den-case-study.md) tem cinco control planes/oito workers distribuídos em dois hosts standalone. Verifique membros etcd; a divisão três/dois não tolera igualmente perda de qualquer host. Apenas um terceiro domínio independente permite sustentar um desenho mais resiliente.

## Expansão e recuperação

Use inventário completo; não exclua control plane de origem com `--limit`. Preserve DNS e credenciais fora do cluster. Expanda um nó por vez, verificando capacidade/LocalPV e reservas para falha. Restauração etcd exige backup, PKI e chave correspondentes e procedimento da versão escolhida; não copie diretório vivo arbitrário nem resete membros existentes para validar screenshots.
