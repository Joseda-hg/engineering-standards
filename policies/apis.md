# API-001 - Prohibit context-sensitive ambient APIs

**Intent.** Domain logic receives time from an injected clock so it stays deterministic and testable.

**Enforcement.**
- C#: `RS0030` bans `DateTime.Now`, `DateTime.UtcNow`, `DateTime.Today`, `DateTimeOffset.Now` and
  `DateTimeOffset.UtcNow`. Inject `TimeProvider` (`Microsoft.Extensions.TimeProvider.Testing` provides
  `FakeTimeProvider` for tests).
- Rust: `clippy::disallowed_methods` bans `std::time::SystemTime::now` (configured in `clippy.toml`).
  `Instant::now` stays allowed: it is a monotonic measurement, not a wall-clock read.

**Exceptions.** One adapter per application may read the wall clock: in C# a scoped
`#pragma warning disable RS0030 // API-001: ... REF-1`, in Rust
`#[expect(clippy::disallowed_methods, reason = "API-001: ...")]`. Both appear in the positive fixtures.

**Limits.** Symbol bans cannot express layering (e.g. "no `DbContext` in UI") or raw SQL policy; those
need architecture tests. Third-party clocks (`chrono::Utc::now`) must be added to the consumer's
`clippy.toml` when the crate is a dependency. Introduce new bans only with a negative fixture.
