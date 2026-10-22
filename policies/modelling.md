# MODEL-001 - Model first; make invalid states unrepresentable

**Intent.** Start a feature with its model, expressed in types, before writing behaviour
(compiler-driven development): if a state cannot be constructed, it cannot be mishandled. "Tests
failing? Improve the code. Tests passing? Improve the tests" becomes "Compile error? Improve the
code. Compiles? Improve the model."

**Techniques.**
- **Sum types over flag fields.** `enum Cat { Alive { hungry: bool }, Dead }` instead of
  `{ alive: bool, hungry: bool }`. C#: a closed set of records, or an enum plus exhaustive switches.
- **Normalise data** (third normal form) instead of deep inheritance; link related data by keys.
- **Newtypes** for identities and units (see DOMAIN-001).
- **Typestate.** Encode the lifecycle in the type so invalid transitions do not compile
  (`Order<Unpaid>` → `pay()` → `Order<Paid>` → `ship()`; C#: `UnpaidOrder.Pay()` → `PaidOrder.Ship()`).
- **Prefer `match`/`switch` over `if`** for domain decisions: the compiler checks exhaustiveness
  (STATE-001); when more nuance is needed, enrich the model instead of adding a condition.

**Enforcement.** Convention, demonstrated by the positive fixtures. Fixtures prove the payoff: a
typestate model rejects shipping an unpaid order at compile time (Rust `compile_fail` doctest; C#
fixture `model-001-typestate-invalid-transition` fails with `CS1061`). Exhaustiveness is enforced by
STATE-001.
