# Agent instructions - engineering-standards

This repository defines reusable *policy*, not consumer application behaviour.

- Run `just quality` before proposing a change; report which checks ran and which could not (missing
  toolchain), with their output.
- Prefer existing compiler and analyzer capabilities before writing custom checks.
- Every new ban, lint or guard needs a negative fixture whose `expected.txt` lists the exact codes and
  counts, plus a positive example when an exception mechanism exists. Update
  `docs/rule-coverage.md` and the policy file in the same change.
- Never claim a rule is automated without a passing fixture.
- Never add blanket `NoWarn`, `#pragma warning disable`, `#[allow]`, `!`, severity downgrades or other
  relaxations merely to make checks pass. Exceptions follow `docs/exceptions.md`.
- Keep `rust/Cargo.toml` lint tables identical to `rust/workspace-lints.toml`.
- Never run `quality-fix` / formatters against `*/fixtures/negative` - those files are wrong on purpose.
- Keep shared rules language-neutral; document limits and exceptions per language.
- Never modify PacificGold or its `upgrade/latest-platform` branch, and do not start PEN-0040 here.
- Version policy changes (VERSIONING.md); consumers pin a tested version. Do not publish or push
  without explicit authorisation.
