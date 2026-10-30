# 02 · Forge — qualify the hardware

[English (default)](02-forge-hardware.md) | [Português (Brasil)](../docs/pt-BR/modules/02-forge-hardware.md) | [Documentation index](../docs/README.md)

Helpers: [host audit](../scripts/host-audit.sh), [selected-GPU diagnosis](../scripts/gpu-diagnose.sh) and the [isolated DRAC5 viewer](../automation/drac5/compose.yml). See the [automation guide](../docs/automation.md) for private inputs and limitations.

The [reviewed hardware snapshot](../docs/den-case-study.md) now supplies CPU models, displayed usable RAM, kernels and boot modes for four hypervisors plus NAS state. It separates two Kubernetes guest hosts from two infrastructure-only hosts. These observations improve sizing; they do not establish final DIMM population, sustained memory stability, chassis power qualification or GPU workload results.

## R710 case

The available history reports an R710 revision II, dual Xeon X5690, dual 870 W PSUs, iDRAC6 Enterprise, Riser 2 x16 and one installed Tesla P4. A second P4 was available. This is a source-reported configuration, not a vendor validation of every R710/GPU combination.

Record service-manual revision, riser PCB part number, slot wiring/power limit, bracket height, airflow and firmware versions. Inspect bent pins and mechanical fit with power disconnected. A physically x16 slot is not sufficient evidence for electrical power, lane count or chassis cooling support.

The added chat clarifies the earlier `10de:11d8` report as a proposed subsystem-ID interpretation; the primary P4 device is expected as `10de:1bb3`. Capture full `lspci -nnk` and subsystem fields before binding. The owner supplied no complete post-install PCI dump in that export. See [the recovered P4 runbook](../docs/r710-p4-vgpu-runbook.md).

X5690 predates AVX. Software built for newer x86 baselines can fail with `Illegal instruction` even if GPU support is correct. Containers use the physical CPU instruction set; they do not emulate missing AVX/AVX2. Check `lscpu` flags and choose/build an appropriate CPU target.

## X99 mixed-memory case

Reported modules:

| Module | Quantity / versions |
|---|---|
| CMK32GX4M1A2666C16, 32 GB | 4: 3.43, 5.42, 3.41, 3.41 |
| CMK32GX4M2A2400C16 kit | 2 × 16 GB, version 3.32 |
| CMK16GX4M1A2400C16 | 2 × 16 GB, versions 3.41 and 3.43 |

Initial single-stick tests found one suspect 32 GB module; later combinations also failed. A black slot identified as DIMM1 CH0 produced POST 60. The root cause was not conclusively established. Slot colors and POST meanings are board-specific; the exact board manual is required.

### Repeatable test plan

1. Record BIOS revision and every relevant setting. Disconnect power before moving DIMMs. Photograph socket/slot layout and label each stick A–H.
2. Load conservative defaults, disable XMP/overclocking, and select a mutually supported JEDEC configuration using the board/CPU documentation. Do not prescribe voltage or slot order from color.
3. Test one known-good stick in the board's specified primary slot. Run multiple complete memory-test passes; record test version, duration and errors.
4. Hold the slot constant and test every stick. Then hold the stick constant and test each supported slot/population position.
5. Test matched sets on one CPU/channel set before mixed population. Increase population one step at a time.
6. If known-good sticks fail in a specific channel, inspect socket pins, seating, cooler pressure and CPU/channel dependencies. Do not keep replacing DIMMs without testing that hypothesis.
7. Retest the final full population cold and warm before hosting persistent workloads.

Zero errors is the acceptance target. An error-free short run is evidence, not a lifetime guarantee. Keep the known-good small configuration as rollback.

## Disk and firmware qualification

Inventory controller mode, disk firmware, SMART/health information, link errors and storage topology. A RAID virtual disk can hide individual-device health; use the controller's appropriate utility. Do not run destructive disk tests on existing data. Test intended spare disks separately. Firmware downloads must match the exact platform and preserve a recoverable path.

## DRAC5 versus iDRAC6

The added DRAC5 chat proves the controller shipped an ELF32 i386 `libavctKVMIO.so`, requiring a matching 32-bit JVM. VNC password authentication worked; **Tools → Session Options → General → Pass all keystrokes to target** fixed keyboard input. The manually downloaded fresh JNLP was the confirmed launch path. A later credential-only browser fetcher was proposed but not user-validated, and its ZIP was not supplied.

See [the full recovered DRAC5 runbook](../docs/drac5-apple-silicon-runbook.md) for login endpoints, cookies, native-library diagnosis, isolated runtime and automation boundaries. Do not treat this as an iDRAC6 recipe without examining that controller's own artifacts.
