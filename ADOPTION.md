# Consumer adoption guide

## C#

1. Pin .NET SDK in the consumer's `global.json` (not centrally: SDK versions depend on the app).
2. Review and copy `csharp/Directory.Build.props` to the **solution root**, merging any existing file. Do not overwrite application properties.
3. Review and copy `csharp/.editorconfig` to the repository root (or manually merge).
4. Register vetted analyzer packages and their pinned versions in consumer build configuration; starter does not silently inject extra packages.
5. Run `dotnet build --no-incremental` and record diagnostics by project, code and toolchain version.
6. Baseline and remove old warnings category by category. Promote `TreatWarningsAsErrors` only after the selected baseline is clean or managed through a clearly scoped transition.

`Directory.Build.props` is discovered through directory ancestry; copying to this standards repo will not affect another repository. `BannedSymbols.txt` needs a compatible analyzer and explicit AdditionalFiles wiring.

## Rust

1. Copy `rust/workspace-lints.toml` sections into the consuming root `Cargo.toml` (do not use an `include` directive).
2. Opt every workspace member into `[lints] workspace = true`.
3. Copy `rust/clippy.toml` to the workspace root and merge any existing config.
4. Pin stable Rust toolchain in `rust-toolchain.toml` in consumer project.
5. Run `cargo fmt --all -- --check`, `cargo clippy --workspace --all-targets -- -D warnings`, and `cargo test --workspace`.

## Migration and ratchet

Existing work such as PacificGold PEN-0040 stays blocked until platform migration gates succeed. Bootstrap the shared policy independently. When integration is unblocked, add the rules as warnings first, capture baseline per diagnostic fingerprint and project, then prevent new warnings while working down legacy debt. Keep migration commits separate from remediation commits.
