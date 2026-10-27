# 08 · Vault — storage and secrets

Automation: `vault` installs LocalPV with a non-default Retain class; `baseline` configures namespace boundaries; [secret-file.sh](../scripts/secret-file.sh) bootstraps private credentials. ESO is opt-in through `lookout`. See the [phase and ownership guide](../docs/automation.md).

## Storage choices

The operational sources describe OpenEBS LocalPV Hostpath and LocalPV LVM with non-default StorageClasses. Both are node-local. A replacement pod on a different node does not automatically gain access to those bytes.

1. Inventory worker disks by stable by-id identifier; inspect partitions, filesystems, mounts, LVM ownership and backups.
2. Prepare only explicitly designated spare disks. Do not assume `/dev/sdb` is disposable just because it was used in an earlier runbook.
3. Install the chosen pinned OpenEBS engines and prerequisites. For LVM, create a named VG only on the intended disks and verify discovery per eligible node.
4. Use delayed binding/topology behavior appropriate to the chosen provisioner and document reclaim policy. Keep StorageClasses non-default until placement expectations are understood.
5. In a disposable namespace, create a PVC and pod, write a sentinel, recreate the pod on the appropriate node and verify the content. Test expansion if supported.
6. Simulate loss/recovery in a maintenance window and prove the backup restore path. A same-node reschedule test is not node-failure recovery.

The old NDM/device cleanup and full-uninstall commands are historical and destructive. Disk wipe requires a separately identified target and an explicit local recovery plan; no wipe script is shipped here.

## PostgreSQL and object storage

The older design prefers PostgreSQL, directory services and MinIO on dedicated VMs with Kubernetes for stateless services. The newer Backstage runbook uses a dedicated PostgreSQL StatefulSet on LocalPV LVM. These are alternatives with different failure and backup properties, not two copies to deploy accidentally.

For Backstage's initial in-cluster option, use a dedicated DB/user, persistent volume, credentials and scheduled logical backups. The source's plaintext DB transport is a historical local setting; use verified TLS for external DB connections. The VM-based option should have independent service startup, restricted firewall access, storage/backup monitoring and tested restore.

MinIO, Spark, dbt, Airflow, Iceberg and MLflow are future data-platform context, not demonstrated installed services. Keep object storage, catalog/metadata and compute lifecycle separate. Record their compatibility and recovery design before adding them.

## Secret ownership

Bootstrap uses Ansible Vault → namespace-local Kubernetes Secret. Base64 is not encryption. Protect Vault passwords/recovery, cluster encryption keys and backup encryption keys outside the cluster.

ESO is planned, with backend intentionally deferred. Choose provider, identity, scope, refresh interval, recovery and rotation before installing stores. Argo owns the operator and ExternalSecret resources after handoff; do not leave Ansible rewriting the same destination Secret.

Avoid one shared AWS credential across all workloads in the generic design. The source's `forest-aws-credentials` convention is retained in history; new deployments should scope identities to workload and target account. Namespace copies do not create distinct IAM identities.

## Rotation exercise

Create replacement upstream credential → update the selected secret authority → reconcile → restart/reload only consumers that need it → prove new access → revoke old credential → prove old access fails. Never print secret data as an acceptance check.

Back up Secret material only into protected encrypted backup sets. GitOps usually restores references, not the values required to decrypt storage or authenticate to upstream systems.
