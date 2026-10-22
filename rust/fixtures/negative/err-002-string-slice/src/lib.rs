/// Fixture.
///
/// # Panics
///
/// Documented so that only the rule under test fires.
#[must_use]
pub fn initial(name: &str) -> &str {
    &name[0..1]
}
