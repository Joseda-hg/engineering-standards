#[must_use]
pub fn first(values: &[u32]) -> u32 {
    *values.first().unwrap()
}
