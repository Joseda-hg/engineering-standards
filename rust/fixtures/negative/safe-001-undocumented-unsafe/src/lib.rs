#[must_use]
#[expect(unsafe_code, reason = "SAFE-001: fixture for an approved exception")]
pub fn read(value: &u32) -> u32 {
    let pointer: *const u32 = value;
    unsafe { *pointer }
}
