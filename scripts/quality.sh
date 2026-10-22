#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 {rust|csharp} PROJECT_PATH" >&2
  exit 2
fi
lang="$1"; project="$2"
case "$lang" in
  rust)
    command -v cargo >/dev/null || { echo "cargo unavailable" >&2; exit 127; }
    cargo fmt --manifest-path "$project/Cargo.toml" --all -- --check
    cargo clippy --manifest-path "$project/Cargo.toml" --all-targets -- -D warnings
    cargo test --manifest-path "$project/Cargo.toml"
    ;;
  csharp)
    command -v dotnet >/dev/null || { echo "dotnet unavailable" >&2; exit 127; }
    dotnet build "$project" --no-incremental
    ;;
  *) echo "Unknown language: $lang" >&2; exit 2 ;;
esac
