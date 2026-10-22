# Rule coverage

What each policy is verified by, per language, and what is **not** automated.

A rule counts as automated only when a negative fixture proves it: the fixture must fail with
exactly the expected diagnostic codes, at the expected number of distinct locations
(`scripts/verify-fixtures.sh`). `just quality-report` regenerates the coverage table from the
fixtures that actually ran; this page explains it.

## Enforcement levels

| Level | Meaning | Strength |
| --- | --- | --- |
| **compiler** | Diagnostic from `csc` / `rustc` | Strongest; cannot be bypassed without a visible suppression |
| **analyzer** | Roslyn analyzer, BannedApiAnalyzers, Clippy, IDE code-style rule run in the build | Strong; suppressions are themselves policed (SUP-001) |
| **msbuild-guard** | `EngineeringStandards.targets` (`ESTD001`-`ESTD005`), strict profile only | Strong for project-level settings; does not see source |
| **formatter** | `rustfmt --check`, `IDE0055` in the C# build | Strong |
| **scan** | `scripts/scan-suppressions.sh` (`SUP001`): line-oriented text scan | Tripwire for review; not a parser, can be evaded with unusual formatting |
| **convention** | Documented and reviewed, no automated check | Relies on review |

## Matrix

| Rule | C# | Rust |
| --- | --- | --- |
| **ERR-001** failure and absence are explicit | compiler `CS8602`, `CS8603` · analyzer `CA1031` · guard `ESTD001` (Nullable must be `enable`) · scan `#nullable disable` | analyzer `clippy::unwrap_used`, `clippy::expect_used` (allowed in tests) · compiler `unused_must_use` (ignored `Result`) |
| **ASY-001** no sync-over-async | analyzer `RS0030`: `Task<T>.Result`, `ValueTask<T>.Result`, all 18 `Task.Wait`/`WaitAll`/`WaitAny` overloads, all 8 awaiter `GetResult()` variants (including `ConfigureAwait(false)`) · compiler `CS4014` · analyzer `CA2016` | compiler `unused_must_use` (future never awaited) |
| **API-001** no ambient wall clock | analyzer `RS0030`: `DateTime.Now/UtcNow/Today`, `DateTimeOffset.Now/UtcNow` | analyzer `clippy::disallowed_methods`: `std::time::SystemTime::now` |
| **STATE-001** exhaustive state handling | compiler `CS8509` · analyzer `IDE0072` (every member listed even when a discard exists) | compiler `E0004` · analyzer `clippy::wildcard_enum_match_arm` |
| **SUP-001** suppressions are narrow and justified | guard `ESTD002` (protected IDs in `NoWarn`/`WarningsNotAsErrors`), `ESTD003` (`TreatWarningsAsErrors` off), `ESTD005` (analyzers off or weakened) · scan `SUP001`: `#pragma warning disable`, `#nullable disable`, `[SuppressMessage]`, `.editorconfig` severity downgrades, `NoWarn` without a reference | analyzer `clippy::allow_attributes`, `clippy::allow_attributes_without_reason` · scan `SUP001`: crate does not inherit workspace lints |
| **SAFE-001** no unreviewed unsafe code | compiler `CS0227` · guard `ESTD004` (`AllowUnsafeBlocks` needs a justification) | compiler lint `unsafe_code` · analyzer `clippy::undocumented_unsafe_blocks` |
| **FMT-001** consistent formatting | analyzer `IDE0055` in the build · `dotnet format whitespace --verify-no-changes` in `quality.sh` (no negative fixture of its own) | formatter `rustfmt --check` |
| **DOMAIN-001** typed identities and units | convention (positive fixtures show `readonly record struct`) | convention (positive fixture shows newtypes) |

Profiles are verified too: under `baseline` the same violations are reported as warnings with exit
code 0 (`profile-baseline` checks in the harness).

The positive fixtures prove the reverse direction: idiomatic code passes with zero warnings under
the strict profile, and the sanctioned exception mechanisms work (`csharp/fixtures/positive/Exceptions`,
`#[expect(..., reason = ...)]` in `rust/fixtures/positive/inventory`).

## Enabled but not fixture-verified

`AnalysisLevel=latest-all` enables every CA rule as a warning, and `clippy::all` enables the default
Clippy groups. They run and, under strict, fail the build, but only the IDs listed above are proven
by fixtures and protected against `NoWarn` (`EngineeringStandardsProtectedDiagnostics`). Notable
examples that run without a dedicated fixture: `CA1849` (sync call inside async method), `CA2007`
(`ConfigureAwait` in libraries), `CA2012` (`ValueTask` misuse), `clippy::await_holding_lock`.

## Not automated (known gaps)

| Gap | Rule | Why / what would close it |
| --- | --- | --- |
| Null-forgiving operator `!` | ERR-001 | No built-in diagnostic; needs a custom analyzer or review |
| `catch` of a specific type that swallows silently | ERR-001 | `CA1031` only covers general exceptions |
| `async void` methods | ASY-001 | No built-in analyzer; `Microsoft.VisualStudio.Threading.Analyzers` (`VSTHRD100`) would add it |
| Blocking calls inside Rust `async fn` | ASY-001 | No stable lint; needs runtime-specific lints or review |
| `let _ = result;` in Rust | ERR-001 | `clippy::let_underscore_must_use` (restriction) not enabled yet |
| Panics other than unwrap/expect (`panic!`, indexing) | ERR-001 | `clippy::panic`, `clippy::indexing_slicing` not enabled yet |
| Layering (e.g. `DbContext` in UI), raw SQL | API-001 | Symbol bans cannot express layers; needs architecture tests (NetArchTest, ArchUnitNET) |
| Clocks from third-party crates (`chrono::Utc::now`) | API-001 | Add the paths to the consumer's `clippy.toml` when the crate is a dependency |
| C# `switch` *statements* | STATE-001 | `IDE0010` not enabled yet |
| Quality of the reason text | SUP-001 | Any text matching `[A-Z][A-Z0-9]+-[0-9]+` is accepted |
| `RUSTFLAGS` / `.cargo/config.toml` lint overrides | SUP-001 | Not scanned yet |
| Multi-line `#pragma` constructs or unusual formatting | SUP-001 | The scan is line-oriented |
| Typed identities and units | DOMAIN-001 | Needs project-specific analyzers or architecture tests |

## Version sensitivity

Diagnostics depend on the toolchain. Results above were produced with the versions recorded in
[validation-results.md](validation-results.md); bump toolchains deliberately and re-run
`just quality` (see [../VERSIONING.md](../VERSIONING.md)). One example: on .NET 9+,
`Task.WaitAll(task)` binds to a new `params ReadOnlySpan<Task>` overload, which needed its own
banned-symbol entry.
