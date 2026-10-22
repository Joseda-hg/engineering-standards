#!/usr/bin/env bash
# Portable quality entrypoint for a C# or Rust project root. Usable from consumer repositories.
#
# Usage: quality.sh {csharp|rust} PATH [--fix]
#
#   csharp PATH   a .sln/.slnx/.csproj file or a directory containing one
#                 check: dotnet build (profile from EngineeringStandards.props), dotnet test,
#                        dotnet format whitespace --verify-no-changes
#                 --fix: dotnet format (whitespace, style and analyzer code fixes)
#   rust PATH     a Cargo workspace or package directory (rust-toolchain.toml is honoured)
#                 check: cargo fmt --check, cargo check, cargo clippy -D warnings, cargo test
#                 --fix: cargo clippy --fix, cargo fmt
#
# Environment:
#   QUALITY_PROFILE     strict (default) | baseline. baseline reports Rust warnings without failing.
#   QUALITY_CARGO_ARGS  package selection for cargo, e.g. "--workspace" (default: cargo's default
#                       members; a virtual workspace without default-members means all members).
set -euo pipefail

usage() { sed -n '2,18p' "$0" >&2; exit 2; }
[[ $# -ge 2 && $# -le 3 ]] || usage
lang="$1"; target="$2"; mode="${3:-check}"
[[ "$mode" == check || "$mode" == --fix ]] || usage
profile="${QUALITY_PROFILE:-strict}"
read -r -a cargo_args <<<"${QUALITY_CARGO_ARGS:-}"

step() { printf '\n==> %s\n' "$*"; }

case "$lang" in
  csharp)
    command -v dotnet >/dev/null || { echo "dotnet unavailable" >&2; exit 127; }
    export DOTNET_CLI_UI_LANGUAGE=en DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1
    case "$target" in
      *.sln|*.slnx) test_target=(--solution "$target") ;;
      *.csproj) test_target=(--project "$target") ;;
      *) test_target=(--directory "$target") ;;
    esac
    if [[ "$mode" == --fix ]]; then
      step "dotnet format $target"
      dotnet format "$target"
      exit 0
    fi
    step "dotnet build $target"
    dotnet build "$target" --no-incremental -nologo
    step "dotnet test ${test_target[*]}"
    dotnet test "${test_target[@]}" --no-build
    step "dotnet format whitespace --verify-no-changes $target"
    dotnet format whitespace "$target" --verify-no-changes
    ;;
  rust)
    command -v cargo >/dev/null || { echo "cargo unavailable" >&2; exit 127; }
    # Run from the workspace so rustup picks up its rust-toolchain.toml.
    cd "$target"
    deny=(-D warnings)
    [[ "$profile" == baseline ]] && deny=()
    if [[ "$mode" == --fix ]]; then
      step "cargo clippy --fix"
      cargo clippy "${cargo_args[@]+"${cargo_args[@]}"}" --all-targets --fix --allow-dirty --allow-staged
      step "cargo fmt"
      cargo fmt --all
      exit 0
    fi
    step "cargo fmt --check"
    cargo fmt --all -- --check
    step "cargo check"
    cargo check "${cargo_args[@]+"${cargo_args[@]}"}" --all-targets
    step "cargo clippy (${profile})"
    cargo clippy "${cargo_args[@]+"${cargo_args[@]}"}" --all-targets -- "${deny[@]+"${deny[@]}"}"
    step "cargo test"
    cargo test "${cargo_args[@]+"${cargo_args[@]}"}"
    ;;
  *) usage ;;
esac
