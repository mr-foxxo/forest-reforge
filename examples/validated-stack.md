# Validated stack record

**Operational evidence is recorded per component.** The [platform snapshot](observed-platform.json) establishes host/node fields and now includes VM placement, selected core-cp01 resources, Argo runtime metrics and discovery-component activity. The [experiment ledger](../docs/den-validations-experiments.md) links those observations to the next functional checks. Fill the driver checksums, guest/runtime versions, CUDA/model and recovery results for each GPU/host/workload tuple; keep its evidence specific to the tested combination.

```yaml
record_id: REQUIRED
status: experimental # source-reported | locally-validated | failed | retired
validation_date: REQUIRED
hardware:
  chassis_and_revision: REQUIRED
  cpu_and_instruction_flags: REQUIRED
  gpu_model_variant_vram: REQUIRED
  pci_identity_and_riser: REQUIRED
  cooling_power_configuration: REQUIRED
host:
  hypervisor_package_version: REQUIRED
  kernel_and_headers: REQUIRED
  firmware_boot_mode: REQUIRED
  driver_package_checksum: REQUIRED
  patch_source_commit_checksum: none_or_REQUIRED
  exposure: passthrough # bare-metal | vgpu
  profile: not_applicable
  licensing_mode: not_applicable
guest:
  os_kernel: REQUIRED
  driver_version: REQUIRED
application:
  cuda_toolkit_runtime: REQUIRED
  framework_commit_build_flags: REQUIRED
  container_digest: REQUIRED
  model_hash_quantization: REQUIRED
results:
  cuda_kernel: pending
  real_workload: pending
  vm_restart: pending
  host_reboot: pending
  temperatures_power: pending
  throughput_latency: pending
rollback:
  bootable_kernel: REQUIRED
  configuration_backup: REQUIRED
```

Add links to redacted logs, test commands, expected output, deviations and upstream support citations. Keep credentials and identifying serials out of public evidence.
