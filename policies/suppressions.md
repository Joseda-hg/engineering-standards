# SUP-001 - Auditable suppression policy

**Intent.** Every suppression states why and links to an issue or approved invariant. Global
configuration is never relaxed to hide new diagnostics.

**Reference format.** A tracker or policy identifier matching `[A-Z][A-Z0-9]+-[0-9]+`, e.g. `PEN-0040`,
`ISSUE-12`, `API-001`.

**Enforcement.**
- C# build guards (strict profile): `ESTD002` protected diagnostics in `NoWarn` /
  `WarningsNotAsErrors`; `ESTD003` `TreatWarningsAsErrors` turned off; `ESTD005` analyzers disabled or
  `AnalysisLevel` lowered.
- C# scan (`scripts/scan-suppressions.sh`, code `SUP001`): `#pragma warning disable` and
  `#nullable disable` need a trailing `// <reason> <REF-1>`; `[SuppressMessage]` needs
  `Justification = "<reason> <REF-1>"`; `.editorconfig` / `.globalconfig` severity downgrades
  (`none`/`silent`/`suggestion`) need a preceding comment with a reference; `NoWarn` entries need an
  XML comment with a reference.
- Rust: `clippy::allow_attributes` (use `#[expect]`, which fails once the suppression is no longer
  needed) and `clippy::allow_attributes_without_reason` (`reason = "..."` is mandatory). The scan
  reports crates that do not inherit the workspace lints.

**Limits.** The scan is line-oriented: it is a CI tripwire for review, not a parser. It does not judge
the quality of the reason text. See [docs/exceptions.md](../docs/exceptions.md) for worked examples.
