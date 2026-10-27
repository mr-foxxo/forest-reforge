#!/usr/bin/env bash
# Build only an existing reviewed llama.cpp checkout; never fetches remote code.
set -Eeuo pipefail
if [[ ${1:-} == --help ]]; then
  printf 'Usage: spellwork-build.sh plan|apply CHECKOUT FULL_COMMIT 52|61|70 NEW_BUILD_DIRECTORY\nRequires a qualified pre-CUDA-13 toolkit and compiler. CPU AVX/FMA is disabled for legacy hosts.\n'
  exit 0
fi
[[ $# == 5 ]] || exit 2
action=$1 checkout=$2 commit=$3 architecture=$4 build=$5
[[ $action == plan || $action == apply ]] || exit 2
[[ $commit =~ ^[a-f0-9]{40}$ && ( $architecture == 52 || $architecture == 61 || $architecture == 70 ) && -d $checkout && ! -e $build ]] || exit 2
[[ $(git -C "$checkout" rev-parse HEAD) == "$commit" ]] || { printf 'Checkout revision differs.\n' >&2; exit 1; }
[[ -z $(git -C "$checkout" status --porcelain) ]] || { printf 'Use a clean reviewed checkout.\n' >&2; exit 1; }
configure=(cmake -S "$checkout" -B "$build" -DGGML_CUDA=ON \
  "-DCMAKE_CUDA_ARCHITECTURES=$architecture" -DGGML_NATIVE=OFF \
  -DGGML_AVX=OFF -DGGML_AVX2=OFF -DGGML_AVX512=OFF -DGGML_FMA=OFF -DGGML_F16C=OFF)
printf '%q ' "${configure[@]}"; printf '\n'
[[ $action == apply ]] || exit 0
"${configure[@]}"
cmake --build "$build" --config Release -j "${REFORGE_BUILD_JOBS:-4}"
printf 'Build finished. Inspect warnings/compile flags; run --help and a small model/operator test.\nA successful compile is not a model or GPU compatibility result.\n'
