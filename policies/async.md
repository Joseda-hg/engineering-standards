# ASY-001 — Avoid sync-over-async

In C# do not use `.Result` / `.Wait()` on tasks in ordinary async execution paths. Prefer `await` and cancellation propagation. In Rust avoid blocking the async executor and use appropriate async I/O. Enforcement: curated analyzer bans for C#; Clippy where covered, plus runtime/architecture tests for Rust. `.Result` and `.Wait()` can also occur on unrelated types; ban qualified symbols, not arbitrary text.
