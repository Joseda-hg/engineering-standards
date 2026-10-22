# ERR-001 - Make failure and absence explicit

**Intent.** Errors are values, not exceptions to an imagined happy path ("railway-oriented
programming"). C#: nullable analysis is on; avoid unjustified `!` and swallowed exceptions; use a
result type or the Try-pattern for expected failures at service boundaries; never return `false` or
`null` to signal failure without saying so in the type. Rust: use `Result<T, E>` and `Option<T>` with
`?` and combinators (`map`, `and_then`, `map_err`, `unwrap_or_default`, `ok_or_else`, ...).

**Not equivalent guarantees.** Nullable annotations are flow analysis, not Rust's type-level
soundness; treat them as strong hints, not proofs.

**Enforcement.**
- C#: `CS8602`/`CS8603` (and the rest of the nullable warnings), `CA1031` (catch of general
  exceptions), guard `ESTD001` (project sets `Nullable` other than `enable`), scan for `#nullable disable`.
- Rust: `clippy::unwrap_used`, `clippy::expect_used`, `unused_must_use` for ignored `Result`s.
  `clippy.toml` allows unwrap/expect inside tests.

**Exceptions.** Tests, and process boundaries that convert all failures (log and map to an error
result), with a scoped suppression carrying a reason and reference.

**Gaps.** The `!` operator, silent catches of specific exception types and `let _ = result;` are not
automated (see docs/rule-coverage.md).

# ERR-002 - No crash paths in production code

**Intent.** *"Never unwrap"* (No Boilerplate, *Rust: Don't Panic*). Memory safety is not enough: a
crash at 4 a.m. is still a crash. Explicit panics, placeholders (`todo!`), implicit panics
(indexing, slicing, overflow, lossy casts) and terminating the process from inside the program are
replaced by handled results. `unwrap()` and friends are prototyping placeholders - "syntactical
todos" - that belong in tests, not in shipped code.

**Enforcement.**
- Rust (Clippy): `panic`, `panic_in_result_fn`, `todo`, `unimplemented`, `unreachable`, `exit`,
  `indexing_slicing`, `string_slice`, `arithmetic_side_effects`, `as_conversions`,
  `unchecked_duration_subtraction` (renamed `unchecked_time_subtraction` in later Clippy). Tests may
  panic: `allow-panic-in-tests`, `allow-indexing-slicing-in-tests`, `allow-unwrap-in-tests`,
  `allow-expect-in-tests` in `clippy.toml`.
- C#: banned `NotImplementedException` constructors (C#'s `todo!`) and `Environment.Exit` /
  `Environment.FailFast` (C#'s `process::exit`; return an exit code from `Main` instead); `CA2201`
  (never throw `System.Exception` or other reserved types - failures are specific).

**Idioms.** Rust: `.get(i)` instead of `[i]`, `checked_*`/`saturating_*` arithmetic, `TryFrom` /
`From` instead of `as`, `Instant::checked_sub`. C#: `TryGetValue`, `ElementAtOrDefault`,
`checked`/`Math.Clamp` where overflow matters, specific exception types.

**Exceptions.** A genuinely unreachable state that the type system cannot express, with
`#[expect(clippy::unreachable, reason = "...")]` - but first try to model the state away (MODEL-001).

**Gaps.** C# has no analyzer for unchecked indexing, overflow or narrowing casts; those remain review
items. Out-of-memory and stack overflow are out of scope for any lint.
