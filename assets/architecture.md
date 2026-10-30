# Forest Reforge diagram assets

[English (default)](architecture.md) | [Português (Brasil)](../docs/pt-BR/assets/architecture.md) | [Documentation index](../docs/README.md)

These source-native Mermaid assets render on GitHub. They are deliberately Markdown rather than fabricated rack photographs or generated logos.

## Trust and delivery topology

```mermaid
flowchart TD
  Paws["Owner paws VPN"] --> Router["OpenWrt management"]
  Paws --> DNS["Independent DNS host"]
  Admin["Human admin VPN"] --> Private["Private platform endpoints"]
  Human["GitHub organization member"] --> Access["Cloudflare Access"]
  Access --> Tunnel["Outbound tunnel connector"]
  Tunnel --> Gateway["Cilium HTTPS Gateway"]
  Gateway --> Backstage["Backstage with app authorization"]
  Private --> Argo["Argo CD"]
  Argo --> Den["Den workloads"]
  Argo --> EKS["Scoped AWS EKS targets"]
```

Absence of an edge here is not a firewall specification; use the explicit access matrix in Module 03.

## GPU qualification decision

```mermaid
flowchart TD
  Identify["Verify card, power and cooling"] --> Mode{"Need sharing?"}
  Mode -->|No| Pass["Full passthrough test VM"]
  Mode -->|Yes| Matrix{"Supported vGPU tuple?"}
  Matrix -->|Yes| Licensed["Licensed manager and guest pairing"]
  Matrix -->|No| Lab["Isolated experimental lane"]
  Pass --> Work["Run actual application kernels"]
  Licensed --> Work
  Lab --> Work
  Work --> Record["Record stack, results and rollback"]
```

## Reconciliation ownership

```mermaid
flowchart TD
  Bootstrap["Ansible substrate and bootstrap secrets"] --> Root["Root Argo Application"]
  Root --> Projects["AppProjects and child Applications"]
  Projects --> Local["Den runtime resources"]
  Projects --> Cloud["AWS runtime resources"]
  External["External account and IAM setup"] --> Cloud
  Secret["Selected secret authority"] --> Local
```
