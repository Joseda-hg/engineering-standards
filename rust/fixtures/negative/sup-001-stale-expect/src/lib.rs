#[must_use]
#[expect(
    clippy::unwrap_used,
    reason = "SUP-001: fixture - the unwrap was removed, the expectation was not"
)]
pub const fn first(values: &[u32]) -> Option<&u32> {
    values.first()
}
