# Changelog

All notable changes. Versioning rules: [VERSIONING.md](VERSIONING.md).

## [0.3.0] - 2026-10-22

Codifies the No Boilerplate recommendations ([ADR 0002](docs/adr/0002-adopt-no-boilerplate-recommendations.md)).
Expect many new diagnostics in existing code: adopt through the baseline profile.

### Added
- **ERR-002** no crash paths. Rust: `panic`, `panic_in_result_fn`, `todo`, `unimplemented`,
  `unreachable`, `exit`, `indexing_slicing`, `string_slice`, `arithmetic_side_effects`,
  `as_conversions`, `unchecked_duration_subtraction`; tests exempt via `allow-panic-in-tests` and
  `allow-indexing-slicing-in-tests`. C#: banned `NotImplementedException` constructors and
  `Environment.Exit`/`FailFast`; `CA2201`.
- **IDIOM-001** Clippy `pedantic` + `nursery` groups and `enum_glob_use`.
- **ASY-002** structured concurrency: `std::thread::spawn` disallowed; `Thread` constructors and
  `ThreadPool` queueing banned in C#.
- **FUNC-001** `CA1822`, `IDE0044`; Rust `missing_const_for_fn` (nursery).
- **STATE-001** `IDE0010` for switch statements.
- **MODEL-001**, **TEST-001**, **AI-001** policies; **DOC-001** ADRs in `docs/adr/` checked by
  `scripts/check-adrs.sh` (`ADR001`); PR template with AI-assistance level.
- Positive fixtures: typestate in both languages (Rust `compile_fail` doctest, C# `CS1061` fixture),
  scoped-thread parallelism, doctests, `proptest` and CsCheck property tests,
  `#![forbid(unsafe_code)]`.
- 24 new negative fixtures (Rust 15, C# 8, docs 1); `docs/developer-workflow.md`.

### Changed
- Existing Rust and C# fixtures tightened so each still fails with exactly one diagnostic under the
  stricter lint set.
- New protected C# diagnostics: `IDE0010`, `CA2201`, `CA1822`, `IDE0044`.

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
