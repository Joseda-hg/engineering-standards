# Exceptions

An exception is a suppression with a **narrow scope**, a **reason** and a **reference** (issue or
policy ID matching `[A-Z][A-Z0-9]+-[0-9]+`). Everything below is accepted by the build guards and by
`scripts/scan-suppressions.sh`; the C# forms are exercised by `csharp/fixtures/positive/Exceptions`
and the Rust form by `rust/fixtures/positive/inventory`.

## C#

Preferred order: fix the code → attribute on the member → `#pragma` around the lines → never project-wide.

```csharp
// Member-level, with justification:
[SuppressMessage("Design", "CA1031:Do not catch general exception types",
    Justification = "ERR-001: process boundary converts all failures, see PEN-123")]
public static bool TryRun(Action action) { /* ... */ }

// Line-level, restored immediately:
#pragma warning disable RS0030 // API-001: sanctioned wall-clock adapter, see PEN-124
public static DateTimeOffset UtcNow() => DateTimeOffset.UtcNow;
#pragma warning restore RS0030
```

Project-level settings that need a recorded justification:

```xml
<!-- SAFE-001 exception: required by ESTD004 -->
<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
<EngineeringStandardsUnsafeJustification>SAFE-001: pointer interop with libfoo, see PEN-125</EngineeringStandardsUnsafeJustification>

<!-- Non-protected diagnostics only; protected IDs fail with ESTD002 under strict. -->
<!-- CA1707: test names use underscores, see PEN-126 -->
<NoWarn>$(NoWarn);CA1707</NoWarn>
```

`.editorconfig` downgrades need a comment with a reference on the line(s) directly above:

```ini
[tests/**.cs]
# CA1707: test method names use underscores, see PEN-126
dotnet_diagnostic.CA1707.severity = none
```

Protected diagnostics (`EngineeringStandardsProtectedDiagnostics`): `nullable`, `CS8509`, `CS4014`,
`CS0227`, `RS0030`, `CA1031`, `CA2016`, `IDE0055`, `IDE0072`, `IDE0010`, `CA2201`, `CA1822`,
`IDE0044`. They can still be suppressed locally (attribute or `#pragma`), never project-wide.
A consumer can extend the list by appending to the property.

## Rust

Use `#[expect]`, not `#[allow]`: an expectation that is no longer needed becomes a warning
(`unfulfilled_lint_expectations`), so stale suppressions surface by themselves. `reason` is mandatory.

```rust
#[expect(clippy::disallowed_methods, reason = "API-001: the only adapter allowed to read the wall clock")]
fn now(&self) -> SystemTime { SystemTime::now() }

#[expect(unsafe_code, reason = "SAFE-001: FFI to libfoo, see PEN-125")]
pub fn read(value: &u32) -> u32 {
    let pointer: *const u32 = value;
    // SAFETY: `pointer` comes from a valid reference.
    unsafe { *pointer }
}
```

Nursery lints may be wrong; say so locally rather than disabling the group (IDIOM-001):

```rust
#[expect(
    clippy::needless_collect,
    reason = "IDIOM-001: nursery false positive - collecting spawns every worker before the first join"
)]
let workers: Vec<_> = lots.chunks(n).map(|chunk| scope.spawn(move || total(chunk))).collect();
```

Crates must keep `[lints] workspace = true`; crate-local `[lints.*]` tables are reported by the scan.

## Review checklist

- Is the scope as small as possible (member/line, not project)?
- Does the reason explain *why the rule does not apply here*, not just restate the rule?
- Does the reference point to an issue that tracks removal, or to an approved invariant?
