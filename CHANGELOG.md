# Changelog

All notable changes. Versioning rules: [VERSIONING.md](VERSIONING.md).

## [0.2.0] - 2026-10-22

First validated release: every automated rule is proven by a negative fixture on pinned toolchains
(.NET SDK 10.0.402, BannedApiAnalyzers 5.6.0, Rust 1.90.0).

### Added
- `csharp/EngineeringStandards.props` / `.targets` / `.globalconfig`: shared defaults, `baseline` and
  `strict` profiles, guard rails `ESTD001`-`ESTD005`.
- `csharp/BannedSymbols.txt`: wall-clock statics and every sync-over-async overload (33 entries).
- Rust lints `unused_must_use`, `wildcard_enum_match_arm`, `undocumented_unsafe_blocks`,
  `allow_attributes`, `allow_attributes_without_reason`; `SystemTime::now` disallowed;
  `rust-toolchain.toml` pin.
- Positive and negative fixtures (C#: 3 positive projects, 24 negative; Rust: 1 positive crate,
  14 negative) and `scripts/verify-fixtures.sh` with exact, counted diagnostic matching.
- `scripts/scan-suppressions.sh` (SUP-001), `scripts/quality-report.sh`, `justfile`
  (`quality`, `quality-fix`, `quality-report`), GitHub Actions on Linux and Windows.
- Policies SAFE-001 and FMT-001; docs: rule coverage, exceptions, adoption, versioning.

### Changed
- STATE-001 in C#: `IDE0072` + `CS8509` with an explicit throwing discard arm.
- Fixtures moved under `csharp/` and `rust/` so they consume the shipped configuration; `templates/`
  removed.
- Rust edition and rustfmt style edition 2024.

### Fixed
- The previous templates never imported the shipped configuration, so CI validated nothing.
- `M:System.Threading.Tasks.Task.Wait` (no parameter list) banned only the parameterless overload.

## [0.1.0] - bootstrap

Initial, unvalidated starter (`chore: bootstrap reusable C# and Rust engineering standards`).
