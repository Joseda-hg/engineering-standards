# STATE-001 - Model meaningful states explicitly

**Intent.** Prefer closed alternatives and exhaustive branch handling for domain states. Avoid default
branches that silently absorb new variants. Prefer `match`/`switch` over `if` for domain decisions,
so the compiler checks every case (see MODEL-001).

**Enforcement.**
- C#: `CS8509` (switch expression misses a named case) and `IDE0072` (every enum member must be listed,
  even when a discard arm exists). Because C# enums can hold unnamed numeric values, the pattern is:
  list every member, then end with `_ => throw new ArgumentOutOfRangeException(...)`. `IDE0072` keeps
  reporting a missing member even though the discard is present, so new members are never absorbed.
  `IDE0010` applies the same rule to `switch` statements.
- Rust: exhaustive `match` is a compiler error (`E0004`); `clippy::wildcard_enum_match_arm` reports `_`
  arms on enums.

**Exceptions.** Intentionally open external protocols, or `#[non_exhaustive]` foreign enums that require
a wildcard, with documented fallback behaviour and a scoped `#[expect(..., reason = "...")]` /
justified suppression.

# DOMAIN-001 - Type important identities and units

**Intent.** Use distinct types for values that can be silently confused (e.g. `LotId`, `Kilos`),
starting at service boundaries. Do not wrap every primitive indiscriminately.

**Enforcement.** Convention and review only. The positive fixtures show the patterns
(`readonly record struct` in C#, newtypes in Rust). Automating this needs project-specific analyzers or
architecture tests.
