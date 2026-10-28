# Validated stack record

**Partial operational evidence is available; no complete GPU/host/workload tuple is certified.** The [reviewed platform snapshot](observed-platform.json) establishes displayed host versions/resources and 13 Ready nodes at kubelet v1.36.4. It does not supply driver checksums, guest/runtime versions, placement, workloads or recovery results. Fill one record per GPU/host/workload combination. Do not use a “works” badge with missing fields.

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
