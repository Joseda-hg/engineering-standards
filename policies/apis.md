# API-001 — Prohibit context-sensitive dangerous APIs

Use injected clocks instead of wall-clock statics in deterministic core logic. For SQL, prefer parameterized queries and restrict raw SQL operations to approved service boundaries. C# `BannedSymbols.txt` targets **specific symbols**; a layering-only prohibition (e.g. `DbContext` in UI) requires architecture tests/analyzer. Rust uses Clippy `disallowed-methods` and `disallowed-types`. Introduce bans only after checking exact symbol paths and adding negative fixtures.
