/// Fixture.
///
/// # Panics
///
/// Documented so that only the rule under test fires.
#[must_use]
pub fn later(value: u32) -> u32 {
    if value == 0 {
        todo!()
    }
    value
}
