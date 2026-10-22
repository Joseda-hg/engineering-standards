# Engineering Standards - uniform entry points. Requires bash (Git Bash on Windows), jq,
# the .NET SDK pinned in global.json and rustup (rust/rust-toolchain.toml pins Rust).

set shell := ["bash", "-euo", "pipefail", "-c"]
# On Windows `bash` on PATH is often WSL; use Git for Windows' bash explicitly.
set windows-shell := ["C:/Program Files/Git/bin/bash.exe", "-euo", "pipefail", "-c"]

csharp_solution := "csharp/fixtures/positive/Positive.slnx"
rust_workspace := "rust"

# List recipes.
default:
    @just --list

# Run every check: positive fixtures, negative fixtures and the suppression scan.
quality: quality-csharp quality-rust scan fixtures

# Apply formatters and automatic fixes to the positive fixtures (never to negative fixtures).
quality-fix:
    bash scripts/quality.sh csharp {{ csharp_solution }} --fix
    bash scripts/quality.sh rust {{ rust_workspace }} --fix

# Run every check and write reports/quality-report.md (non-zero exit if anything failed).
quality-report out="reports":
    bash scripts/quality-report.sh {{ out }}

# C#: build (strict profile), test and verify formatting of the positive fixtures.
quality-csharp:
    bash scripts/quality.sh csharp {{ csharp_solution }}

# Rust: fmt, check, clippy -D warnings and test on the positive fixtures.
quality-rust:
    bash scripts/quality.sh rust {{ rust_workspace }}

# Verify that every negative fixture fails with exactly its expected diagnostics.
fixtures lang="all":
    bash scripts/verify-fixtures.sh {{ lang }}

# Report suppressions without a reason and reference (SUP-001).
scan:
    bash scripts/scan-suppressions.sh --exclude '*/fixtures/negative' csharp rust scripts
