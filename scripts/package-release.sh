#!/usr/bin/env bash
# Generic deliverable only; raw reference/history and all local state stay private.
set -Eeuo pipefail
umask 077
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ${1:-} == --help ]]; then
  printf 'Usage: package-release.sh NEW_OUTPUT_TAR_GZ\nPackages generic docs/code only. Excludes reference, IDE and private/runtime state.\n'
  exit 0
fi
[[ $# == 1 && $1 == *.tar.gz && ! -e $1 ]] || exit 2
output=$(cd -- "$(dirname -- "$1")" && pwd)/$(basename -- "$1")
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
mkdir "$stage/forest-reforge"
# Explicit public roots only. Never archive the workspace wholesale.
for item in README.md CONTRIBUTING.md RELEASE.md assets docs examples modules scripts automation tests; do
  rsync -a --exclude='private/' --exclude='.env' --exclude='__pycache__/' --exclude='.DS_Store' \
    --exclude='*.pyc' --exclude='*.retry' -- "$root/$item" "$stage/forest-reforge/"
done
cp "$root/.gitignore" "$stage/forest-reforge/.gitignore"
COPYFILE_DISABLE=1 tar -C "$stage" -czf "$output" forest-reforge
printf 'Created generic archive: %s\nReview its contents before public publication. Historical reference links require the local source copy.\n' "$output"
