# Agent instructions — engineering-standards

This repository defines reusable *policy*, not consumer application behavior.

- Prefer existing compiler and analyzer capabilities before writing custom checks.
- Every new ban or lint promotion needs a positive and negative fixture and passing CI.
- Keep shared rules language-neutral; document limits and exceptions per language.
- Never add blanket `NoWarn`, `#pragma warning disable`, `#[allow]`, `!`, or policy relaxations merely to make checks pass.
- Never modify PacificGold's `upgrade/latest-platform` or unblock PEN-0040 here.
- Version policy changes; consumer adoption should pin a tested version.
- Report which checks actually ran and which require toolchains not installed.
