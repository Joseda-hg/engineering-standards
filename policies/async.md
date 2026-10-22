# ASY-001 - Avoid sync-over-async

**Intent.** Do not block on tasks in ordinary async execution paths; prefer `await` and propagate
cancellation. In Rust, do not block the async executor and do not drop futures without awaiting them.

**Enforcement.**
- C#: BannedApiAnalyzers (`RS0030`) bans `Task<T>.Result`, `ValueTask<T>.Result`, every overload of
  `Task.Wait`, `Task.WaitAll` and `Task.WaitAny`, and `GetResult()` on every awaiter type (including
  `ConfigureAwait(false).GetAwaiter().GetResult()`). Symbols are qualified, so `.Result` on unrelated
  types is not affected, and `await` itself is not flagged. `CS4014` reports un-awaited tasks inside
  async methods; `CA2016` reports a `CancellationToken` that is not forwarded.
- Rust: `unused_must_use` reports a future that is created and never awaited.

**Note on overloads.** A BannedApiAnalyzers method ID without a parameter list bans only the
parameterless overload. Every overload is therefore listed explicitly; re-check the list when the
target framework changes (new overloads such as `WaitAll(params ReadOnlySpan<Task>)` appear).

**Exceptions.** Synchronous entry points that must block (e.g. `Main` without async support, legacy
interop). Suppress at the call site with a reason and reference. Tool-generated files under `obj/`
(the xunit.v3 entry point blocks in `Main`) are exempt via `csharp/.editorconfig`.

**Gaps.** `async void`, blocking I/O inside async methods (`CA1849` runs but has no fixture), and
blocking calls inside Rust `async fn` are not proven by fixtures.

# ASY-002 - Structured concurrency: what is started is joined

**Intent.** Concurrency (interleaving work, mostly I/O) and parallelism (doing work at the same time,
mostly CPU) are different problems; do not reach for an async runtime by default (No Boilerplate,
*Async Isn't Real and Can't Hurt You*). Every piece of work that is started must be awaited or joined
within a visible scope, so failures surface and borrowed data stays valid. Unscoped work forces
`'static` data (Rust) or silently swallows exceptions (C# fire-and-forget).

**Preferred tools.**
- Rust: `std::thread::scope` (threads may borrow; all are joined at the end of the scope) or Rayon
  `par_iter()` for data parallelism; async only for I/O-bound concurrency, with scoped/structured
  task groups where the runtime offers them.
- C#: `await` on every task, `Task.WhenAll` for fan-out, `Parallel.ForEach(Async)` for data
  parallelism; no fire-and-forget.

**Enforcement.**
- Rust: `std::thread::spawn` is a disallowed method (`clippy::disallowed_methods`).
- C#: `RS0030` bans every `Thread` constructor and every `ThreadPool.QueueUserWorkItem` /
  `UnsafeQueueUserWorkItem` overload.

**Exceptions.** Long-lived background workers owned by the process (e.g. a server's listener
thread), with a scoped suppression and a reference explaining who joins or stops them.

**Gaps.** `_ = Task.Run(...)` in C# and detached async tasks in Rust runtimes are not detected.
