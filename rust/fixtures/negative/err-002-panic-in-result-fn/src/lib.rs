/// Fixture.
///
/// # Panics
///
/// Documented so that only the rule under test fires.
///
/// # Errors
///
/// Never, in practice.
pub fn check(value: u32) -> Result<u32, String> {
    assert!(value > 0, "positive");
    Ok(value)
}
