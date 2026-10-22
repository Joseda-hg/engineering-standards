# FMT-001 - Consistent, tool-owned formatting

**Intent.** Formatting is decided by tools, not by review.

**Enforcement.**
- C#: `IDE0055` runs in the build (`EnforceCodeStyleInBuild`) using the `.editorconfig` formatting
  options; `scripts/quality.sh` also runs `dotnet format whitespace --verify-no-changes`.
  `just quality-fix` applies `dotnet format`.
- Rust: `cargo fmt --check` with `rustfmt.toml` (edition and style edition 2024, Unix newlines);
  `just quality-fix` applies `cargo fmt`.
- Line endings are normalised to LF by `.gitattributes`, so Windows checkouts behave like Linux.

**Exceptions.** Generated code (`generated_code = true` in `.editorconfig`). Avoid `#[rustfmt::skip]`
except for tables whose alignment carries meaning, with a comment.
