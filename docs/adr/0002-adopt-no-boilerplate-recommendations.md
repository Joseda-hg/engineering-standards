# 0002. Adopt the No Boilerplate recommendations

## Status

Accepted — 2026-10-22

## Context

Tris Oatman's *No Boilerplate* talks (public-domain scripts at
`github.com/0atman/noboilerplate/scripts`, notes at `namtao.com`) give a consistent, opinionated
view of writing software that does not crash. They are mostly about Rust, but most of the ideas
carry over to C#. Sources reviewed (2026-10-22): *Rust: Don't Panic*, *My 2026 Rust Toolkit*,
`namtao.com/rust`, *Your Code Can Be Perfect*, *Rust on Rails*, *Compiler-Driven Development*,
*Make Invalid States Unrepresentable* (data modelling), *Rust Testing*, *Functional Rust / const fn*,
*Async Isn't Real and Can't Hurt You*, *Misusing Macros*, *Stop Writing Rust*, *Rust Is Boring*,
*Plain-Text Team*, *Running an Agile Team*, *AI Is Not Designed for You*, the AI policy and the
draft *AI Permissions* note.

The recurring recommendations are:

1. **Never panic.** `unwrap`/`expect` are prototyping placeholders ("syntactical todos") that must not
   reach production; implicit panics (indexing, slicing, overflow, casts) are just as bad. Clippy with
   `pedantic` + `nursery` + a "deny panics" set enforces it; tests are exempt.
2. **The linter teaches.** Enable `pedantic` and `nursery`; answer false positives locally.
3. **Errors are values** (railway-oriented programming): return `Result`, never `false`/`null`; use
   combinators instead of unwrapping.
4. **Model first; make invalid states unrepresentable.** Sum types, normalised data, newtypes,
   typestate; prefer `match` over `if` so the compiler checks every case (compiler-driven development).
5. **Pure core.** Prefer pure (`const`) functions; push side effects to the edges; immutable by default.
6. **Do not reach for async by default.** Parallelism ≠ concurrency; use scoped threads or Rayon so
   work is joined and can borrow; avoid `'static`-everything runtimes where not needed.
7. **Test in layers.** Doctests and examples, white- and black-box tests, property tests, fuzzing.
8. **`#![forbid(unsafe_code)]`** unless the crate really needs `unsafe`.
9. **Tooling:** bacon / watchexec loop, nextest, cargo-generate, devenv; nightly Rust.
10. **Plain-text team:** decisions written down (ADRs), Markdown in the repo, asynchronous threads.
11. **AI:** humans must be able to read and own every change; levels of assistance should be explicit.
12. **Macros:** never do in a macro what a function can do.

## Decision

We adopt the recommendations as policies, enforced wherever a tool can prove them and documented as
conventions otherwise. Each automated rule has a negative fixture (see `docs/rule-coverage.md`).

| # | Recommendation | Rust | C# | Policy |
| --- | --- | --- | --- | --- |
| 1 | Never panic | `unwrap_used`, `expect_used`, `panic`, `panic_in_result_fn`, `todo`, `unimplemented`, `unreachable`, `exit`, `indexing_slicing`, `string_slice`, `arithmetic_side_effects`, `as_conversions`, `unchecked_duration_subtraction`; test exemptions in `clippy.toml` | Banned `NotImplementedException` (= `todo!`), `Environment.Exit`/`FailFast` (= `exit`); `CA2201` (no `throw new Exception`) | ERR-001, ERR-002 |
| 2 | Linter teaches | `pedantic` + `nursery` groups, `enum_glob_use` | Already `AnalysisLevel=latest-all` | IDIOM-001 |
| 3 | Errors are values | (as before) `unused_must_use` | (as before) nullable, `CA1031` | ERR-001 |
| 4 | Model first | `E0004`, `wildcard_enum_match_arm`; typestate example with a `compile_fail` doctest | `CS8509`, `IDE0072`, new `IDE0010` for switch statements; typestate example and a `CS1061` fixture | STATE-001, MODEL-001 |
| 5 | Pure core | `missing_const_for_fn` (nursery) | `CA1822` (static members), `IDE0044` (readonly fields) | FUNC-001 |
| 6 | Structured concurrency | `std::thread::spawn` disallowed in favour of `std::thread::scope` | Banned `Thread` constructors and `ThreadPool.(Unsafe)QueueUserWorkItem` | ASY-002 |
| 7 | Test layers | Positive fixture has doctests, a `compile_fail` doctest, unit, integration and `proptest` tests | Positive fixture has CsCheck property tests | TEST-001 (convention) |
| 8 | Forbid unsafe | `#![forbid(unsafe_code)]` recommended for crates without unsafe; shown in the positive fixture | `AllowUnsafeBlocks=false` + `ESTD004` (as before) | SAFE-001 |
| 10 | Plain-text decisions | ADRs in `docs/adr/`, checked by `scripts/check-adrs.sh` | same | DOC-001 |
| 11 | AI ownership | PR template declares the assistance level; a human reads and owns every line | same | AI-001 (convention) |
| 12 | Macros | Convention in TEST/IDIOM docs | Source generators: same rule | IDIOM-001 (convention) |

Adapted or rejected:

- **Nightly Rust — rejected.** Tris has used nightly since 2020 for compile-time and feature gains.
  These standards are pinned to a stable toolchain because diagnostics must be reproducible across
  machines and CI, and lint sets differ between nightlies. Revisit only with a pinned nightly date.
- **`deny` levels — adapted.** The lints are configured at `warn` and denied in CI with
  `-D warnings` (strict profile). Same effect in CI, while the baseline profile still lets existing
  code bases measure before they comply.
- **`unchecked_time_subtraction` — adapted.** The pinned Clippy 1.90 still calls it
  `unchecked_duration_subtraction`; rename when the toolchain is bumped.
- **`forbid(unsafe_code)` in workspace lints — adapted.** `forbid` cannot be locally excepted, which
  would remove SAFE-001's reviewed-exception path for crates that genuinely need `unsafe`. The
  workspace keeps `unsafe_code` (denied in CI), and crates without unsafe add `#![forbid(unsafe_code)]`.
- **devenv / Nix, bacon, watchexec, nextest, cargo-generate — recommended, not required.** Listed in
  `docs/developer-workflow.md`; the standards only require bash, just, jq, rustup and the .NET SDK.
- **Release profile (`panic = "abort"`, LTO, size optimisation) — not adopted.** Deployment-specific.
- **Crate choices (color-eyre, thiserror, jiff, clap, rayon, serde, sqlx, ...) — listed, not
  required.** Library choice belongs to the consuming project.
- **Agile process (no estimates, demo-driven iterations) — out of scope.** Team process, not code
  standards; not encoded here.
- **AI policy — adapted.** His content policy forbids AI-written scripts; for code we adopt the
  narrower, enforceable part: disclosure of the assistance level and full human review and ownership.

## Consequences

- Rust code must handle every failure path explicitly; idiomatic, panic-free code becomes the
  default, and prototypes keep their `unwrap()`s inside tests.
- `pedantic` + `nursery` produce many diagnostics on existing code; adopters start in the baseline
  profile (ADOPTION.md). Nursery false positives are answered with
  `#[expect(clippy::..., reason = "...")]` — the positive fixture contains a real one
  (`needless_collect` on scoped-thread spawning).
- C# gains crash-path, switch-statement, purity and structured-concurrency rules; `latest-all`
  already covered most of "the linter teaches".
- New rules are a MINOR release (0.3.0) per VERSIONING.md.
- The talks are opinionated and evolve; re-review them when bumping toolchains and record changes
  in a new ADR.
