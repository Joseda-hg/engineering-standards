#[must_use]
pub fn read(value: &u32) -> u32 {
    let pointer: *const u32 = value;
    // SAFETY: `pointer` comes from a valid reference.
    unsafe { *pointer }
}
