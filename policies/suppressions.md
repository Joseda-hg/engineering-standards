# SUP-001 — Auditable suppression policy

Every suppression must state why and link to an issue or approved invariant. C#: `#pragma warning disable`, `NoWarn`, or nullable `!` merit scrutiny but not every occurrence can be safely classified with regex. Rust: `#[allow(...)]` and `#[expect(...)]` need context. CI should report suspicious diffs for review; AST-based enforcement is a future goal. Never relax global configurations merely to hide new diagnostics.
