# FUNC-001 - Pure core, effects at the edges

**Intent.** Most logic should be pure: output depends only on input, no I/O, no mutation of shared
state. Pure functions are deterministic, cacheable, trivially parallel and testable without mocks.
Push I/O (clock, network, disk, console) to thin adapters at the edges and inject them (see API-001).
Data is immutable by default; data flows through transformations (iterators/LINQ, result
combinators) rather than being mutated in place.

**Enforcement.**
- Rust: `clippy::missing_const_for_fn` (nursery) - a function that can be `const` is, which is the
  closest thing Rust has to a checked purity marker. Immutability is the language default.
- C#: `CA1822` (a member that touches no instance state is `static`) and `IDE0044` (a field assigned
  only at construction is `readonly`). Records with `init` properties are preferred for data.

**Gaps.** Neither language checks purity in general; a `static` C# method can still do I/O.
Review that domain code does not reach for ambient I/O.
