/// Fixture.
///
/// # Panics
///
/// Documented so that only the rule under test fires.
#[must_use]
pub fn check(value: u32) -> u32 {
    match value {
        0 => panic!("zero"),
        other => other,
    }
}
