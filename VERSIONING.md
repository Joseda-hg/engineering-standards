# Versioning and distribution

## Version scheme

The standards are versioned as a whole with Semantic Versioning, released as Git tags `vMAJOR.MINOR.PATCH`.
The current version is recorded in `CHANGELOG.md` and in `EngineeringStandardsVersion`
(`csharp/EngineeringStandards.props`); both must match the tag.

Consumers pin an exact version (submodule commit, vendored `VERSION`, or package version) and upgrade
deliberately, so a release may add diagnostics without breaking anyone who has not opted in.

| Change | Bump | Examples |
| --- | --- | --- |
| Consumers must change their integration | **MAJOR** | Renamed or removed property, profile, diagnostic code or rule ID; files moved; profile semantics changed |
| Existing code may get new diagnostics | **MINOR** | New rule, lint, banned symbol or protected diagnostic; SDK / Rust toolchain or analyzer package bump; a fixed false negative (e.g. the missing `Task.Wait` overloads) |
| No new diagnostics for existing code | **PATCH** | Documentation, scripts, CI, fixed false positives |

Rule IDs (`ERR-001`, ...) and diagnostic codes (`ESTD001`, `SUP001`) are stable: never reuse an ID for a
different meaning.

## Release checklist

1. `just quality` is green locally and in CI (Linux and Windows).
2. Every new or changed rule has a negative fixture with exact expected diagnostics and, where an
   exception mechanism exists, a positive example.
3. `docs/rule-coverage.md` and the relevant `policies/*.md` are updated.
4. `CHANGELOG.md` has an entry; `EngineeringStandardsVersion` matches.
5. `just quality-report` output is attached to the release.
6. Tag `vX.Y.Z` on `main`.

## Toolchain bumps

Diagnostics depend on the .NET SDK (Roslyn), BannedApiAnalyzers, rustc and Clippy versions. To bump:

1. Update `global.json`, `BannedApiAnalyzersVersion`, or `rust/rust-toolchain.toml` (one at a time).
2. Run `just quality`. New diagnostics in positive fixtures are either fixed or justified; changed
   diagnostics in negative fixtures are investigated (new overloads, renamed lints).
3. Re-generate the banned-symbol IDs by reflection when the target framework changes; a method ID
   without a parameter list bans only the parameterless overload.
4. Release as MINOR.

## Distribution roadmap

1. **Now:** Git tag + submodule or vendored copy (see ADOPTION.md).
2. **Next:** NuGet package `EngineeringStandards.CSharp` carrying the props/targets/globalconfig/banned
   symbols under `buildTransitive/`, so consumers pin with a `PackageReference`.
3. **Rust:** Cargo cannot inherit lints across workspaces, so the tables stay copied. A
   `check-drift` script (like the `lint-drift` check in `scripts/verify-fixtures.sh`) can compare a
   consumer's `Cargo.toml` against the pinned `workspace-lints.toml`.
