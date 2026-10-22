# Engineering Standards

Versioned, language-agnostic engineering policies with native enforcement for **C#** and **Rust**.

> Status: **bootstrap / v0.1**. This is a starter repository, not a production-certified analyzer package. Adoption is opt-in and pinned per consumer. Do not auto-apply to an existing migration branch.

## Principles

1. Express shared intent in `policies/`, enforce with native language tools.
2. Prefer compiler > analyzer > CI check > documented convention; never claim parity where none exists.
3. Keep tooling reproducible and pinned in consuming projects.
4. New code must not introduce new violations. Legacy baselines are project-local, not centrally shared.
5. Suppressions require narrow scope, a reason, and an issue reference.
6. Rules are tested using deliberately valid and invalid examples before promotion to error.

## Layout

- `policies/`: rule catalog, evidence level, exemptions, rationale.
- `profiles/`: baseline, strict, legacy policy targets.
- `csharp/`: MSBuild and editorconfig integration templates, optional banned symbols.
- `rust/`: workspace lints, Clippy configuration, formatting.
- `templates/`: tiny compileable examples for integration smoke tests.
- `scripts/quality.sh`: portable, explicit quality entrypoint for project roots.
- `agents/AGENTS.md`: instructions for AI coding agents.

## Try the fixtures

```bash
./scripts/quality.sh rust templates/rust
./scripts/quality.sh csharp templates/csharp
```

Requires installed `cargo`, `rustfmt`, `clippy` or `.NET SDK` respectively. The script runs checks and does not update project files.

## Adopting

Start with `profiles/baseline.toml`. Copy and adapt the corresponding native templates into your project; commit the chosen standards version in its README/CI. See `ADOPTION.md`. Promote rules individually after test coverage and baseline remediation. Do **not** copy everything blindly.

## Scope and current limitations

- No custom analyzer, published NuGet package, policy compiler, or synchronization CLI yet.
- `.editorconfig` and MSBuild properties are repository/project-specific placement decisions, not automatically inherited from an unrelated Git repository.
- C# `BannedSymbols.txt` supports *symbol-level* bans, not architectural layer detection. A rule such as `DbContext` in UI components needs an additional architectural analyzer/test.
- Rust Clippy workspace lints require individual crates to opt in with `[lints] workspace = true`.
- Analyzer warnings from different SDK/compiler versions are not directly comparable: pin tools when ratcheting.

## Roadmap

1. Validate tools/fixtures in CI across C# and Rust.
2. Implement curated Banned Symbols and disallowed-methods lists, each with negative fixtures.
3. Design an annotated diagnostic fingerprint baseline for consumer repos.
4. Package C# analyzer defaults as `buildTransitive` NuGet assets; create a Rust pinned sync strategy.
5. Add rule coverage reporting (compiler / analyzer / architecture / convention).

Related consumer issue: `PEN-0040` (blocked until `upgrade/latest-platform` has passed migration gates).
