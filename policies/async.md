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
