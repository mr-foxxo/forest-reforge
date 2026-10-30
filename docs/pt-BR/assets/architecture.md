# Diagramas do Forest Reforge

[English (default)](../../../assets/architecture.md) | [Português (Brasil)](architecture.md) | [Índice](../README.md)

Fontes Mermaid renderizáveis no GitHub, compartilhando o mesmo desenho conceitual da edição inglesa. O texto dos diagramas está em português.

## Confiança e entrega

```mermaid
flowchart TD
  Paws["VPN paws do proprietário"] --> Router["Gerenciamento OpenWrt"]
  Paws --> DNS["DNS independente"]
  Admin["VPN de administradores"] --> Private["Endpoints privados"]
  Human["Membro da organização GitHub"] --> Access["Cloudflare Access"]
  Access --> Tunnel["Conector de túnel de saída"]
  Tunnel --> Gateway["Gateway HTTPS Cilium"]
  Gateway --> Backstage["Backstage com autorização própria"]
  Private --> Argo["Argo CD"]
  Argo --> Den["Workloads do Den"]
  Argo --> EKS["Destinos EKS limitados"]
```

Ausência de seta não especifica regra de firewall. Use a política explícita do [módulo 03](../modules/03-paths-network.md).

## Decisão de qualificação GPU

```mermaid
flowchart TD
  Identify["Confirmar placa, energia e refrigeração"] --> Mode{"Precisa compartilhar?"}
  Mode -->|Não| Pass["VM de teste com passthrough completo"]
  Mode -->|Sim| Matrix{"Combinação vGPU suportada?"}
  Matrix -->|Sim| Licensed["Manager e convidado licenciados"]
  Matrix -->|Não| Lab["Experimento isolado"]
  Pass --> Work["Executar kernels reais da aplicação"]
  Licensed --> Work
  Lab --> Work
  Work --> Record["Registrar versões, resultados e reversão"]
```

## Responsabilidade pela reconciliação

```mermaid
flowchart TD
  Bootstrap["Ansible: base e segredos iniciais"] --> Root["Aplicação raiz Argo"]
  Root --> Projects["AppProjects e aplicações filhas"]
  Projects --> Local["Recursos de execução do Den"]
  Projects --> Cloud["Recursos de execução AWS"]
  External["Configuração externa de contas e IAM"] --> Cloud
  Secret["Autoridade de segredos escolhida"] --> Local
```

Defina um responsável por objeto e registre a transferência Ansible → Argo conforme [automação](../automation.md).
