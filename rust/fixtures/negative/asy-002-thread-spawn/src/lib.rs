#[must_use]
pub fn background() -> bool {
    std::thread::spawn(|| 1).join().is_ok()
}
