# Validation results

Recorded runs of the real toolchains against this repository, the defects they exposed, and what
remains open. Regenerate the raw report with `just quality-report` (written to `reports/`, not committed).

## v0.3.0 runs - No Boilerplate codification (2026-10-22)

| Environment | Commit | Command | Result |
| --- | --- | --- | --- |
| Ubuntu 24.04 container, clean clone, CI toolchain install | `f8425c1` | `just quality` + `just quality-report` | **PASS** |
| Windows 11 (PowerShell → Git Bash) | `f8425c1` + report rendering fix | `just quality-report` | **PASS** |
| Docker shellcheck / actionlint | `f8425c1` | all scripts / workflow | Clean |
| **GitHub Actions** ubuntu-24.04 and windows-2025 ([run 39720956465](https://github.com/Joseda-hg/engineering-standards/actions/runs/39720956465)) | `474f1d0` | `just quality` + `just quality-report` | **PASS** (both jobs; Windows 5m41s) |

- C# positive: 0 warnings, 0 errors; 12 / 12 tests (including CsCheck properties and typestate).
- Rust positive: clean under `-D warnings` with `pedantic`, `nursery` and the full ERR-002 set;
  8 unit/property tests, 2 integration tests, 1 doctest, 1 `compile_fail` doctest (typestate).
- **66 / 66** fixture and consistency checks: C# 32 fixtures + baseline profile, Rust 29 fixtures +
  baseline profile + lint drift, 1 language-neutral (ADR) fixture, version consistency.

Findings during this round:

| Finding | Resolution |
| --- | --- |
| Clippy 1.90 does not know `unchecked_time_subtraction` (the name used in the talks) | Use `unchecked_duration_subtraction`; rename on the next toolchain bump (ADR 0002) |
| `clippy::needless_collect` (nursery) fires on collecting scoped-thread handles; following it would join each thread before spawning the next, silently serialising the work | Kept the `collect()`; `#[expect(clippy::needless_collect, reason = ...)]` - the documented way to answer nursery false positives |
| `pedantic`/`nursery` flagged secondary issues in 9 existing and several new fixtures (`missing_const_for_fn`, `missing_panics_doc`, `manual_assert`, `must_use_candidate`, `unused_async`) | Fixtures rewritten to contain exactly one violation each |
| `string_slice` does not co-fire `indexing_slicing` on `&s[0..1]` | Expectation corrected to the observed single code |
| `--locked` refused the stale `Cargo.lock` after adding fixture crates | Lockfile regenerated and committed (intended behaviour) |
| `CA1720` (identifier contains type name) on a fixture method named `Double` | Renamed |
| The report under-counted rules proven by one fixture for several rules, and had no column for language-neutral fixtures | Multi-rule `# rule:` tags and a language-neutral column |
| Python edits turned `\1` into control bytes in one script line | Rewritten from code points; repository scanned for control characters |

## v0.2.0 runs (2026-10-22, commit `3a1dd83`)

| Environment | Command | Result |
| --- | --- | --- |
| Windows 11 (PowerShell → Git Bash via `justfile`) | `just quality-report` | **PASS** in 69 s |
| Ubuntu 24.04 container, clean clone, toolchains installed exactly as in CI | `just quality` then `just quality-report` | **PASS** (both); fixtures 23 s, scripts `-rwxr-xr-x` |
| Windows | `just quality-fix` on a clean tree | No-op (empty `git diff`) |
| Windows | `just quality-fix` after breaking C# and Rust formatting | Restored both files (empty `git diff`) |
| Docker `koalaman/shellcheck:stable` | shellcheck on `scripts/*.sh` | Clean |
| Docker `rhysd/actionlint` | `.github/workflows/quality.yml` | Clean |

Toolchain: .NET SDK 10.0.402 (Roslyn 5.9), BannedApiAnalyzers 5.6.0, xunit.v3 4.0.2 on
Microsoft.Testing.Platform, rustc / Clippy / rustfmt 1.90.0, just 1.45.0, jq 1.7-1.8.

| Check | Result |
| --- | --- |
| C# positive build (strict, `latest-all`, warnings as errors) | 0 warnings, 0 errors (3 projects) |
| C# tests (`dotnet test`, xunit.v3) | 9 / 9 passed |
| `dotnet format whitespace --verify-no-changes` | Clean |
| Rust `cargo fmt --check`, `cargo check`, `cargo clippy -D warnings` | Clean |
| Rust tests | 4 / 4 passed (2 unit, 2 integration) |
| Suppression scan over shipped config, positive fixtures and scripts | No findings |
| Negative fixtures + consistency checks | **42 / 42** passed: C# 24 fixtures + baseline profile; Rust 14 fixtures + baseline profile + lint drift; version consistency |

*(Superseded: the workflow has since run on GitHub - see the v0.3.0 table above.)* At the time of
this run the GitHub Actions workflow had not run on GitHub, because nothing had been published (by
instruction). The container run reproduces the Linux job step by step (SDK installed from
`global.json` with `dotnet-install`, Rust from `rust-toolchain.toml`, just 1.45.0, jq), but the
Windows runner image and the pinned actions are only verified by actionlint until the first push.

## Defects found and fixed

| # | Finding | How it was found | Fix |
| --- | --- | --- | --- |
| 1 | The original templates never imported the shipped configuration (`templates/csharp` sat outside `csharp/`; `templates/rust` declared its own lints). CI was green while validating nothing | Baseline run + audit | Fixtures moved under `csharp/` and `rust/`; Rust lint tables drift-checked |
| 2 | `M:System.Threading.Tasks.Task.Wait` banned only the parameterless overload: 17 of 18 `Wait`/`WaitAll`/`WaitAny` overloads (including `Wait(TimeSpan)` and .NET 9+ `WaitAll(params ReadOnlySpan<Task>)`) were allowed | Counting diagnostics per fixture instead of comparing code sets | Every overload listed (IDs generated by reflection); one call per overload in the fixture |
| 3 | `task.ConfigureAwait(false).GetAwaiter().GetResult()` and `ValueTask` awaiters bypassed the ban | Review while fixing #2 | 8 awaiter `GetResult` entries, all proven |
| 4 | Suppressing `CS8524` conflicted with `IDE0072`, which demands a default arm | Positive fixture failed | STATE-001 redesigned: list every member, then a throwing discard; no compiler suppression |
| 5 | xunit.v3's generated `XunitAutoGeneratedEntryPoint.cs` blocks in `Main`; BannedApiAnalyzers reports in generated code despite `generated_code = true` | Positive test project failed | `RS0030` scoped off for `obj/**` only, with a referenced comment |
| 6 | xunit.v3 on .NET 10 refuses the VSTest path | `dotnet test` error | `global.json` opts into Microsoft.Testing.Platform |
| 7 | A project could set `RunAnalyzers=false`, `EnforceCodeStyleInBuild=false` or lower `AnalysisLevel` and pass strict silently | Writing the coverage document | Guard `ESTD005` with two fixtures |
| 8 | `rustup` reads `rust-toolchain.toml` from the current directory, not from `--manifest-path`: the pin was silently ignored when cargo ran from the repo root | Review | Scripts `cd` into the workspace |
| 9 | From PowerShell, `bash` resolves to WSL | Running scripts from PowerShell | `justfile` uses Git Bash explicitly on Windows |
| 10 | `core.autocrlf=true` would turn LF files into CRLF on Windows and trip `end_of_line = lf` / rustfmt | Audit | `.gitattributes` forces LF |
| 11 | New scripts were committed as 100644 (`core.filemode=false`) | `git ls-files -s` | Marked executable; Linux run confirms `-rwxr-xr-x` |
| 12 | Imprecise fixtures (extra `CA1062`, `match_like_matches_macro`) | Exact matching | Fixtures rewritten to contain a single violation |
| 13 | A stale `Cargo.lock` would be rewritten silently in CI | Adding a fixture crate | Committed lockfile; cargo runs with `--locked` |

The harness was itself mutation-tested: setting `RS0030` to `none`, deleting a single banned overload,
removing a lint from one or both lint tables each made the expected fixtures fail
(e.g. `RS0030*17` instead of `RS0030*18`).

## Known limitations

- The suppression scan is line-oriented; unusual formatting can evade it, and it does not judge the
  quality of reasons.
- Only fixture-listed diagnostics are protected from project-wide `NoWarn`; other `latest-all` rules
  run but can be silenced per project.
- `.editorconfig` entries override the global config; the scan reports unjustified downgrades, but
  the build itself cannot see them.
- Not automated: `!` null-forgiving operator, `async void`, blocking inside Rust `async fn`, layering
  rules, DOMAIN-001 (full list in [rule-coverage.md](rule-coverage.md)).
- The `legacy` fingerprint ratchet is not implemented.
- No published package: distribution is by Git tag (submodule or vendored copy; first tag `v0.3.0`).

## Next steps (prioritised)

1. ~~Protect and tag~~ - done 2026-10-22: the repository is public, `main` is protected by a ruleset
   (no deletion or force push, pull request required, both `quality` matrix checks required and up
   to date), and `v0.3.0` is tagged at `9a30bdf`.
2. **Pilot adoption** in one small, non-PacificGold repository using the baseline → strict phases;
   capture friction in ADOPTION.md.
3. **Close high-value gaps** with fixtures: `clippy::let_underscore_must_use`, `VSTHRD100` for
   `async void`, a `CA1849` fixture, a C# analyzer for the `!` operator and unchecked
   indexing/overflow (ERR-002 parity). (`IDE0010` and the Clippy panic lints were closed in v0.3.0.)
4. **NuGet package** `EngineeringStandards.CSharp` (`buildTransitive`) and a Rust lint drift checker for
   consumers.
5. **Fingerprint ratchet** (`legacy` profile) for large existing code bases.
6. **Architecture tests** template for layering rules (e.g. no `DbContext` in UI).
7. PacificGold / PEN-0040: only after `upgrade/latest-platform` passes its integration gates.
