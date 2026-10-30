# 08 · Vault — armazenamento, dados e segredos

[English (default)](../../../modules/08-vault-storage-secrets.md) | [Português (Brasil)](08-vault-storage-secrets.md) | [Índice](../README.md)

A fase `vault` instala LocalPV e StorageClass não padrão com `Retain`. [Automação](../automation.md) descreve LVM opcional, cujos VGs devem existir previamente. A role não formata discos nem executa `pvcreate`/`vgcreate`.

## Persistência

LocalPV é ligado ao nó, sem replicação automática. Use consumidor agendado para testar PVC, escreva sentinela/checksum, substitua pod e confirme afinidade. Recuperação de falha de nó exige restauração real; reagendar no mesmo nó não demonstra isso. Antes de apagar namespace/PVC, inspecione dados e política de retenção.

O NAS observado tem dois pools ONLINE de um disco, sem prova de exportação, backup ou restore. Não o declare substituto validado do LocalPV.

PostgreSQL pode ficar em VM dedicada ou StatefulSet com LocalPV dedicado, com riscos distintos. Defina localização, dono dos dados, usuários/bancos, TLS para conexões externas, backup lógico/físico e restauração por consulta. MinIO, Spark, dbt, Airflow, Iceberg e MLflow são contexto futuro, sem implantação demonstrada.

## Segredos e rotação

Bootstrap usa Ansible Vault para Secrets Kubernetes por namespace. Base64 não é criptografia. Preserve senha Vault, chave de criptografia do cluster e chaves de backup fora do cluster. Instalar ESO não define backend: escolha provedor, identidade, escopo, refresh, recuperação e rotação antes de SecretStore/ExternalSecret.

Ao transferir para GitOps, Argo controla operador e referências; não deixe Ansible sobrescrever o mesmo Secret. Use identidade AWS por workload/destino; cópias em namespaces não criam identidades IAM diferentes.

Exercício: criar credencial substituta → atualizar autoridade escolhida → reconciliar → recarregar consumidores necessários → testar acesso novo → revogar antiga → provar rejeição antiga. Não imprima valores como evidência. Backups de segredos precisam de proteção e criptografia; GitOps recupera referências, sem garantir os valores para descriptografar ou autenticar.
