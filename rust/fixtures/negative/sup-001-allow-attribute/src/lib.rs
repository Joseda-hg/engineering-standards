/// Returns the first value.
///
/// # Panics
///
/// Panics when `values` is empty.
#[must_use]
#[allow(clippy::unwrap_used)]
pub const fn first(values: &[u32]) -> u32 {
    *values.first().unwrap()
}
