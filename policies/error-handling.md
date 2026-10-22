# ERR-001 — Make failure and absence explicit

Use ordinary language mechanisms to propagate and handle failure. C#: enable nullable analysis; avoid unjustified `!` and swallowed exceptions, consider `Result<T>` for expected failures at service boundaries. Rust: use `Result<T,E>` and `Option<T>`; avoid `unwrap`/`expect` in production paths where failure is possible. Exceptions: tests, startup invariants, proven assertions with narrow explanation. **Not equivalent guarantees:** nullable annotations are not Rust ownership/type soundness.
