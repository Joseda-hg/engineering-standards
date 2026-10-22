#[must_use]
#[allow(clippy::unwrap_used)]
pub fn first(values: &[u32]) -> u32 {
    *values.first().unwrap()
}
