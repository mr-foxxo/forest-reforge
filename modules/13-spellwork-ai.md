# 13 · Spellwork — AI on older compute

Helper: [spellwork-build.sh](../scripts/spellwork-build.sh) builds a reviewed checkout at an exact commit with explicit GPU and legacy CPU options. A compatible toolkit/revision is required; see the [automation guide](../docs/automation.md).

**Proposed qualification workflow.** No tokens/sec, model-size promise or measured power result is claimed for the originating den.

## Match workload to resource

Start with a small model and short context, then measure. Weight memory is only part of capacity: KV cache, runtime buffers, concurrency and framework allocations also consume VRAM. Quantization changes memory and numerical behavior, and its kernel may require newer instructions than the model itself.

V100 can be useful for selected FP16 workloads; P4/M40 need architectures and kernels appropriate to their generations. Do not prescribe BF16/FP8 or a current fused-attention path across all cards. A fallback implementation may be slower but valid; unsupported GPU instructions cannot be fixed by adding RAM.

Current vLLM's documented CC 7.5 minimum excludes all three target cards. A pinned older V100-compatible stack is an experiment requiring model/operator validation. A container with a modern CUDA runtime cannot restore removed Maxwell/Pascal/Volta compiler targets or missing wheel kernels.

## Candidate llama.cpp build experiment

Use an isolated compute VM with a compatible driver/toolkit/compiler. Review and select a specific upstream revision first. This snippet assumes an existing checkout at that reviewed revision; it does not fetch or run an unpinned installer.

```bash
# Run in the reviewed llama.cpp checkout; select one target:
# M40=52, P4=61, V100=70. Requires a toolkit retaining that target.
cmake -S . -B build-reforge \
  -DGGML_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=70 \
  -DGGML_NATIVE=OFF
cmake --build build-reforge --config Release -j 4
```

Inspect the pinned revision's CPU flags as well: `GGML_NATIVE=OFF` alone does not guarantee an X5690-compatible binary. Disable unsupported AVX/AVX2/FMA build options as required by that revision and inspect the actual compiler command line. Select a revision retaining the desired GPU kernels; an architecture flag cannot recreate deleted source support.

Run the built binary's `--help`, then use its documented model/offload/context arguments with a checksum-recorded model. Start with a short local request and increase context/concurrency only after measuring memory and temperature. Bind serving to loopback/private networking until auth, limits and intended routing are configured.

## PyTorch diagnostic

Inside the intended framework environment:

```python
import torch
print('torch', torch.__version__, 'runtime', torch.version.cuda)
assert torch.cuda.is_available(), 'CUDA unavailable'
print('device', torch.cuda.get_device_name(0))
print('capability', torch.cuda.get_device_capability(0))
print('compiled_arches', torch.cuda.get_arch_list())
x = torch.ones((128, 128), device='cuda', dtype=torch.float32)
y = x @ x
torch.cuda.synchronize()
assert torch.allclose(y, torch.full_like(y, 128))
print('small FP32 operation passed')
```

A passing matrix operation validates only that operation. Test the model's attention, quantization and sampling kernels separately. `no kernel image is available` often points to missing architecture targets; `Illegal instruction` may be CPU-side; out-of-memory needs a full allocation/context review.

## Benchmark protocol

Record model/license/hash, tokenizer, quantization, prompts or dataset hash, context/output length, seed, warmup count, repeated runs and concurrent clients. Measure time-to-first-token, prompt and generation throughput separately, p50/p95 latency, errors, peak VRAM/RAM, wall power and thermal steady state. Use the same workload for comparisons.

Compare CPU-only, GPU passthrough and vGPU only when the application versions and profile resources are recorded. Report accuracy/quality checks alongside speed. Prefer total service energy and cost per completed workload over a GPU wattage label.

For Kubernetes GPU placement, qualify the device plugin/operator with the driver first, label/taint GPU nodes, request actual GPU resources, and prevent incompatible images from scheduling there. Keep a simple VM-based fallback while experimenting.
