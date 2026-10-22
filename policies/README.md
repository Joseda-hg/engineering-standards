# Rule catalog

Identifiers are stable. Each rule describes (a) intent, (b) implementation per language,
(c) level of guarantee, (d) exceptions and (e) tests. `policies/*.md` describe intent;
[docs/rule-coverage.md](../docs/rule-coverage.md) states what is actually verified.

| ID | Policy | C# | Rust |
| --- | --- | --- | --- |
| ERR-001 | Failure and absence are explicit | nullable (compiler) + CA1031 + ESTD001 | unwrap/expect lints + `unused_must_use` |
| ASY-001 | No sync-over-async | RS0030 banned symbols + CS4014 + CA2016 | `unused_must_use` on futures; rest is review |
| API-001 | No ambient wall clock | RS0030 banned symbols | `clippy::disallowed_methods` |
| STATE-001 | Exhaustive state handling | CS8509 + IDE0072 | E0004 + `clippy::wildcard_enum_match_arm` |
| SUP-001 | Suppressions are narrow, justified and visible | ESTD002/003/005 guards + suppression scan | `allow_attributes(_without_reason)` + scan |
| SAFE-001 | No unreviewed unsafe code | CS0227 + ESTD004 | `unsafe_code` + `undocumented_unsafe_blocks` |
| FMT-001 | Consistent formatting | IDE0055 in the build + `dotnet format` | `rustfmt --check` |
| DOMAIN-001 | Typed identities and units at boundaries | convention | convention |

Diagnostic codes emitted by this repository:

| Code | Source | Meaning |
| --- | --- | --- |
| `ESTD001` | `csharp/EngineeringStandards.targets` | `Nullable` is not `enable` (strict) |
| `ESTD002` | `csharp/EngineeringStandards.targets` | A protected diagnostic is silenced via `NoWarn`/`WarningsNotAsErrors` |
| `ESTD003` | `csharp/EngineeringStandards.targets` | `TreatWarningsAsErrors` turned off under strict |
| `ESTD004` | `csharp/EngineeringStandards.targets` | `AllowUnsafeBlocks` without `EngineeringStandardsUnsafeJustification` |
| `ESTD005` | `csharp/EngineeringStandards.targets` | Analyzers disabled or `AnalysisLevel` lowered under strict |
| `SUP001` | `scripts/scan-suppressions.sh` | Suppression without a reason and reference |

Exceptions follow [suppressions.md](suppressions.md) and [docs/exceptions.md](../docs/exceptions.md).
