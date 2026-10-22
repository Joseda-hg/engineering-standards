# Developer workflow

Recommended, not required: the standards only need bash, just, jq, rustup and the .NET SDK. The
workflow follows No Boilerplate's compiler-driven development (ADR 0002).

## The loop

1. **Model first.** Write the types (enums/records, newtypes, typestate) before behaviour
   (MODEL-001). Compile; do not run.
2. **Red → green with the compiler.** Compile error? Improve the code. Compiles? Improve the model.
   Stay in a compiling state as much as possible; break big changes into compilable steps.
3. **Read the first error.** The first error in the compiler output - not in the editor - is the one
   to fix; later errors are often consequences.
4. **Obey the linter** (IDIOM-001), answering real false positives with `#[expect(..., reason)]`.
5. **Then test** what the types cannot express (TEST-001).
6. `just quality-fix` before committing; `just quality` before pushing.

## Watchers

| Tool | Command |
| --- | --- |
| [bacon](https://dystroy.org/bacon/) | `bacon clippy` in a terminal next to the editor |
| [watchexec](https://watchexec.github.io/) | `watchexec -c -e rs "cargo clippy && cargo test"` |
| .NET | `dotnet watch build` / `dotnet watch test` |

## Optional Rust tools

| Tool | Use |
| --- | --- |
| `cargo-nextest` | Faster test runner with retries, slow-test detection and JUnit output |
| `cargo-mutants` | Mutation testing (do the tests notice a changed line?) |
| `cargo-fuzz` | Fuzzing parsers and untrusted input |
| `cargo-shear` | Remove unused dependencies |
| `cargo-generate` | Scaffold projects from templates |
| devenv / Nix | Reproducible per-project toolchains and services |

## Library suggestions

The consuming project chooses its libraries; these are common, mature defaults:

| Need | Rust | C# |
| --- | --- | --- |
| Application errors | `color-eyre` / `anyhow` | result types or Try-pattern |
| Library errors | `thiserror` | specific exception types |
| Time | `jiff` (or `chrono`), behind an injected clock | `TimeProvider` |
| CLI | `clap` (derive) | `System.CommandLine` |
| Data parallelism | `rayon` | `Parallel.ForEach` / PLINQ |
| Serialisation | `serde` | `System.Text.Json` |
| SQL | `sqlx` (compile-time checked queries) | Dapper / EF Core |
| Property tests | `proptest` | CsCheck / FsCheck |
