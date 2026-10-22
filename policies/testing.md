# TEST-001 - Test in layers, starting where the compiler stops

**Intent.** The type system removes whole classes of bugs (MODEL-001); test what remains, from the
lightest technique to the heaviest:

| Layer | Rust | C# |
| --- | --- | --- |
| Happy path | doctests (`cargo test` runs them), runnable `examples/`, `assert!`/`debug_assert!` | xunit facts, XML-doc examples |
| Compile-time proof | `compile_fail` doctests for typestate and API misuse | negative compile fixtures |
| Black box | `tests/` integration tests through the public API | separate test project |
| White box | `#[cfg(test)] mod tests` beside the code | `InternalsVisibleTo` only when needed |
| Probabilistic | `proptest` (shrinks to a minimal failing case) | CsCheck / FsCheck |
| Adversarial | `cargo fuzz` for parsers and untrusted input | SharpFuzz |

Prototype freely *in tests*: `unwrap`, `expect`, `panic` and indexing are allowed there
(`clippy.toml`). For TDD: tests failing → improve the code; tests passing → improve the tests.

**Enforcement.** Convention. The positive fixtures demonstrate every layer up to property tests
(Rust: doctest, `compile_fail` doctest, unit, integration, `proptest`; C#: xunit.v3 and CsCheck
properties). Optional tools: `cargo-nextest` (faster, retries, slow-test detection),
`cargo-mutants` (mutation testing).
