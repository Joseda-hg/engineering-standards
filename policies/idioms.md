# IDIOM-001 - Let the linter teach

**Intent.** Strict linting does two things: it teaches the idioms of the language and it stops bugs.
Turn on the broad lint groups and follow their advice; when a lint is wrong, say so locally with a
reason instead of turning the group off. Run the linter continuously while writing code (e.g.
`bacon clippy`) and fix the *first* error the compiler reports.

**Enforcement.**
- Rust: `clippy::pedantic` and `clippy::nursery` groups on (denied in CI), plus `enum_glob_use`
  (qualified variant names say where a name comes from). Fixtures prove both groups are active.
- C#: `AnalysisLevel=latest-all` (every CA rule) and `EnforceCodeStyleInBuild`, guarded by `ESTD005`.

**False positives.** Nursery lints are explicitly allowed to have false positives. Answer them with
`#[expect(clippy::lint_name, reason = "IDIOM-001: why the lint is wrong here")]`; the positive
fixture contains a real case (`needless_collect` on scoped-thread spawning, where collecting is what
makes the threads run in parallel).

**Macros and source generators.** Never do in a macro (or C# source generator) what you can do in a
function. Convention.
