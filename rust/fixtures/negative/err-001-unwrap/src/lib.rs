/// Returns the first value.
///
/// # Panics
///
/// Panics when `values` is empty.
#[must_use]
pub const fn first(values: &[u32]) -> u32 {
    *values.first().unwrap()
}
