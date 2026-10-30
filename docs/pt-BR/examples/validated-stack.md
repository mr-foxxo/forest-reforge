# Registro de combinação validada

[English (default)](../../../examples/validated-stack.md) | [Português (Brasil)](validated-stack.md) | [Índice](../README.md)

Registre evidência por componente e combinação de hardware/software. O [snapshot](../../../examples/observed-platform.json) estabelece campos observados, posicionamento e métricas selecionadas, sem validar GPU/modelo/restauração automaticamente. O [registro de experimentos](../den-validations-experiments.md) indica próximos testes.

Mantenha as chaves e os estados abaixo em inglês, preenchendo versões e resultados reais. `REQUIRED` indica campo obrigatório; `pending` indica resultado ainda pendente. O estado `locally-validated` exige os testes pertinentes à combinação exata.

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

Inclua comandos, saídas esperadas, logs sem dados privados, desvios e referências de suporte do fabricante. Registre checksum de driver/patch, convidado, runtime, CUDA/modelo e recuperação por GPU/host/workload. Não publique credenciais ou seriais identificáveis.
