# SAFE-001 - No unreviewed unsafe code

**Intent.** Unsafe code is an explicit, reviewed, documented exception.

**Enforcement.**
- C#: `AllowUnsafeBlocks` is `false`, so `unsafe` is a compiler error (`CS0227`). Turning it on under the
  strict profile requires an `EngineeringStandardsUnsafeJustification` property (guard `ESTD004`).
- Rust: the `unsafe_code` lint rejects unsafe code; a sanctioned exception uses
  `#[expect(unsafe_code, reason = "...")]`, and `clippy::undocumented_unsafe_blocks` then requires a
  `// SAFETY:` comment on every unsafe block.

**Recommendation.** A Rust crate that needs no unsafe code declares `#![forbid(unsafe_code)]` at its
root (as the positive fixture does): `forbid`, unlike the workspace-level lint, cannot be overridden
by `#[expect]` further down.

**Exceptions.** Interop and measured performance work, reviewed and referenced in the justification.
