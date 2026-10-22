# STATE-001 — Model meaningful states explicitly

Prefer closed alternatives and exhaustive branch handling for domain states. Avoid silent default branches that mask new variants. C#: compiler switch diagnostics where applicable and analyzer rules; Rust: exhaustive `match` over enums. Exceptions: intentionally open external protocols, with documented fallback behavior. Do not globally deny valid wildcard patterns without context.

# DOMAIN-001 — Type important identities and units

Use distinct types for values that can be silently confused (e.g. `LoteId`, `Kilos`), starting at service boundaries. Do not wrap every primitive indiscriminately. C#: `readonly record struct` or equivalent; Rust: newtype structs. Enforcement initially architectural/review, until specific project-level tests/analyzers exist.
