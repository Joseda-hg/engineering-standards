# ERR-001 - Make failure and absence explicit

**Intent.** Use ordinary language mechanisms to propagate and handle failure. C#: nullable analysis is
on; avoid unjustified `!` and swallowed exceptions; consider a result type for expected failures at
service boundaries. Rust: use `Result<T, E>` and `Option<T>`; no `unwrap`/`expect` in production paths.

**Not equivalent guarantees.** Nullable annotations are flow analysis, not Rust's type-level
soundness; treat them as strong hints, not proofs.

**Enforcement.**
- C#: `CS8602`/`CS8603` (and the rest of the nullable warnings), `CA1031` (catch of general
  exceptions), guard `ESTD001` (project sets `Nullable` other than `enable`), scan for `#nullable disable`.
- Rust: `clippy::unwrap_used`, `clippy::expect_used`, `unused_must_use` for ignored `Result`s.
  `clippy.toml` allows unwrap/expect inside tests.

**Exceptions.** Tests, startup invariants and process boundaries that convert all failures (log and
map to an error result). Use a scoped suppression with a reason and reference, e.g.
`[SuppressMessage("Design", "CA1031", Justification = "ERR-001: process boundary, see PEN-123")]` or
`#[expect(clippy::expect_used, reason = "ERR-001: config validated at startup, see PEN-123")]`.

**Gaps.** The `!` operator, silent catches of specific exception types, `let _ = result;` and
`panic!`/indexing in Rust are not automated (see docs/rule-coverage.md).
