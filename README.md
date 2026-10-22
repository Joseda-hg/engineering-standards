# Engineering Standards

Versioned, language-neutral engineering policies with native, tested enforcement for **C# (.NET 10)**
and **Rust**.

> Status: **v0.2.0**. Every rule marked as automated is proven by a negative fixture that must fail
> with exactly the expected diagnostics; see [docs/rule-coverage.md](docs/rule-coverage.md) for what
> is and is not automated. Adoption is opt-in and pinned per consumer ([ADOPTION.md](ADOPTION.md)).

## Principles

1. Express shared intent in `policies/`; enforce it with native tools (compiler > analyzer > build guard
   > CI scan > documented convention). Never claim parity where none exists.
2. A rule is automated only when a negative fixture proves it and a positive fixture shows compliant
   code passing.
3. Toolchains are pinned; diagnostics from different versions are not comparable.
4. Suppressions are narrow, justified and referenced; shared configuration is never relaxed to make a
   build pass.

## Commands

Requires bash (Git Bash on Windows), [just](https://just.systems), jq, the .NET SDK from `global.json`
and rustup (the Rust version comes from `rust/rust-toolchain.toml`).

| Command | What it does |
| --- | --- |
| `just quality` | Positive fixtures (C#: build under strict, test, format check; Rust: fmt, check, clippy `-D warnings`, test), suppression scan, all negative fixtures |
| `just quality-fix` | `dotnet format` and `cargo clippy --fix` + `cargo fmt` on the positive fixtures |
| `just quality-report` | Everything above, written to `reports/quality-report.md` with a rule-coverage matrix |
| `just fixtures [csharp\|rust]` | Negative fixtures only |
| `just scan` | Suppression scan only |

`scripts/quality.sh {csharp|rust} PATH [--fix]` is the same checker for consumer repositories.

## Layout

| Path | Contents |
| --- | --- |
| `policies/` | Rule catalog: intent, enforcement, exceptions, gaps |
| `csharp/` | `EngineeringStandards.props/.targets/.globalconfig`, `BannedSymbols.txt`, `.editorconfig` (shipped) |
| `csharp/fixtures/positive` | `Inventory` (+ xunit.v3 tests) and `Exceptions` (sanctioned escape hatches) |
| `csharp/fixtures/negative` | One project per violation, each with `expected.txt` |
| `rust/` | `workspace-lints.toml`, `clippy.toml`, `rustfmt.toml` (shipped), `rust-toolchain.toml`, self-test workspace |
| `rust/fixtures/{positive,negative}` | Positive crate and one crate per violation |
| `scripts/` | `quality.sh`, `verify-fixtures.sh`, `scan-suppressions.sh`, `quality-report.sh` |
| `profiles/` | What `baseline` / `strict` / `legacy` mean and which switches select them |
| `docs/` | Rule coverage, exceptions, validation results |
| `agents/AGENTS.md` | Instructions for AI coding agents |

The fixtures sit *under* the shipped configuration so they pick it up through the same discovery a
consumer gets (`Directory.Build.props`, `.editorconfig`, `clippy.toml`, `rustfmt.toml`); the Rust
workspace lint tables are drift-checked against `rust/workspace-lints.toml`.

## Documentation

- [docs/rule-coverage.md](docs/rule-coverage.md) - compiler vs analyzer vs guard vs scan vs convention, and known gaps
- [docs/exceptions.md](docs/exceptions.md) - how to suppress correctly in each language
- [ADOPTION.md](ADOPTION.md) - distribution, wiring and progressive rollout
- [VERSIONING.md](VERSIONING.md) and [CHANGELOG.md](CHANGELOG.md)
- [docs/validation-results.md](docs/validation-results.md) - recorded runs, findings and next steps

Related consumer issue: `PEN-0040` stays blocked until PacificGold's `upgrade/latest-platform` passes
its integration gates; this repository does not modify PacificGold.
