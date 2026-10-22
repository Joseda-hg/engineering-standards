# Rule catalog

Identifiers are stable; each rule must describe (a) intent, (b) implementation per language, (c) level of guarantee, (d) exceptions, (e) tests.

| ID | Policy | C# | Rust |
| --- | --- | --- | --- |
| ERR-001 | No unexamined failure/absence escapes | nullable + analyzers + review | `Result`/`Option` + Clippy |
| ASY-001 | Avoid sync-over-async | async analyzers | Clippy + review |
| API-001 | No disallowed ambient APIs | banned symbols/custom lint | Clippy disallowed methods |
| STATE-001 | Prefer exhaustive state handling | CS8509 and targeted design | `match`/enum exhaustiveness |
| SUP-001 | Exceptions must be narrow and documented | CI scan/review | CI scan/review |
| DOMAIN-001 | Prevent ID/unit confusion at boundaries | strong wrapper types | newtypes |

`policies/*.md` describe intent, not a claim that every tool currently enforces it.
