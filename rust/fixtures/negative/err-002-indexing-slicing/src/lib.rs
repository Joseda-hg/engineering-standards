/// Fixture.
///
/// # Panics
///
/// Documented so that only the rule under test fires.
#[must_use]
pub fn third(values: &[u32]) -> u32 {
    values[2]
}
