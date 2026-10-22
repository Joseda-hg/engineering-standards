# Adoption guide

How to bring the standards into another repository, progressively and with a pinned version. Read
[docs/rule-coverage.md](docs/rule-coverage.md) first: it states what each rule actually enforces.

> **PacificGold.** Do not apply these standards to PacificGold, and do not start PEN-0040, until
> `upgrade/latest-platform` has passed its integration gates. Keep migration commits and remediation
> commits separate when that work is unblocked.

## 1. Get a pinned copy

Pick one distribution method and record the version (e.g. `v0.2.0`) in the consumer's README or CI.

| Method | How | Update |
| --- | --- | --- |
| **Git submodule** (recommended while there is no package) | `git submodule add <url> build/engineering-standards` then `git -C build/engineering-standards checkout v0.2.0` | Check out a newer tag, run the consumer's CI, commit the submodule pointer |
| **Vendored copy** | Copy the files listed below into `build/engineering-standards/` and add a `VERSION` file containing the tag | Re-copy from the new tag; review the diff |
| **NuGet package** (planned) | `EngineeringStandards.CSharp` with `buildTransitive` props/targets | `PackageReference` version bump |

Files a C# consumer needs: `csharp/EngineeringStandards.props`, `csharp/EngineeringStandards.targets`,
`csharp/EngineeringStandards.globalconfig`, `csharp/BannedSymbols.txt`, and `csharp/.editorconfig`
(merged into the repository root `.editorconfig`). A Rust consumer needs `rust/workspace-lints.toml`
(tables copied into the root `Cargo.toml`), `rust/clippy.toml` and `rust/rustfmt.toml` (copied to the
workspace root). `scripts/quality.sh` and `scripts/scan-suppressions.sh` are optional CI helpers.

## 2. Wire it in

### C#

1. Pin the SDK in the consumer's `global.json` (the standards are validated on the version in this
   repository's `global.json`).
2. In the consumer's `Directory.Build.props` (create or merge; do not overwrite application properties):

   ```xml
   <Project>
     <PropertyGroup>
       <EngineeringStandardsProfile>baseline</EngineeringStandardsProfile>
     </PropertyGroup>
     <Import Project="$(MSBuildThisFileDirectory)build/engineering-standards/csharp/EngineeringStandards.props" />
   </Project>
   ```

3. In the consumer's `Directory.Build.targets`:

   ```xml
   <Project>
     <Import Project="$(MSBuildThisFileDirectory)build/engineering-standards/csharp/EngineeringStandards.targets" />
   </Project>
   ```

4. Merge `csharp/.editorconfig` into the repository root `.editorconfig`. Severities live in the global
   config and apply everywhere; an `.editorconfig` entry overrides them, which is why the suppression
   scan reports unjustified downgrades.
5. Test projects: xunit.v3 on .NET 10 needs `"test": { "runner": "Microsoft.Testing.Platform" }` in
   `global.json`.

`Directory.Build.props` is found through directory ancestry, so the import must be in the consumer
repository; files in this repository do not affect another one.

### Rust

1. Pin the toolchain in `rust-toolchain.toml` (validated version: `rust/rust-toolchain.toml`).
2. Copy the `[workspace.lints.*]` tables from `rust/workspace-lints.toml` into the root `Cargo.toml`
   (Cargo has no include directive) and copy `clippy.toml` and `rustfmt.toml` to the workspace root.
3. Opt members in one at a time with `[lints]\nworkspace = true`.
4. CI: `scripts/quality.sh rust .` (fmt, check, clippy, test). Set `QUALITY_CARGO_ARGS=--workspace` if
   the root is a package rather than a virtual workspace.

## 3. Roll out progressively

| Phase | C# | Rust | Exit criterion |
| --- | --- | --- | --- |
| 0. Inventory | Import with `baseline`; build and count diagnostics per code (command below) | Copy lints; `QUALITY_PROFILE=baseline scripts/quality.sh rust .` | Inventory recorded per project and code, with toolchain versions |
| 1. New code strict | New projects set `<EngineeringStandardsProfile>strict</EngineeringStandardsProfile>` in their `.csproj` | New crates opt into `[lints] workspace = true`; CI runs Clippy with `-D warnings` for them | New projects are green under strict |
| 2. Remediate | One project / diagnostic category per change; no blanket `NoWarn` | One crate / lint per change | Project is clean |
| 3. Promote | Switch the project (or the folder's `Directory.Build.props`) to `strict` | Opt the crate in | Strict in CI |
| 4. Repository-wide strict | Set `strict` in the root `Directory.Build.props` | All members opted in, `-D warnings` everywhere | Whole repository green |

Inventory command for C#:

```bash
dotnet build -p:EngineeringStandardsProfile=baseline --no-incremental 2>&1 \
  | grep -oE 'warning [A-Z]+[0-9]+' | sort | uniq -c | sort -rn
```

Diagnostics from different SDK / Clippy versions are not comparable: pin toolchains before
measuring, and re-measure after every toolchain bump. A fingerprint-based "no new warnings" ratchet
(`profiles/legacy.toml`) is planned, not implemented.

## 4. Exceptions

Follow [docs/exceptions.md](docs/exceptions.md): narrow scope, a reason, and a reference
(`[A-Z][A-Z0-9]+-[0-9]+`). Never relax a shared configuration file to make a build pass; protected
diagnostics cannot be silenced through `NoWarn` under the strict profile.

## 5. Upgrading

Read [CHANGELOG.md](CHANGELOG.md) and [VERSIONING.md](VERSIONING.md). Upgrade on a branch, run the
consumer's CI under strict, and fix or justify new diagnostics in the same change.
