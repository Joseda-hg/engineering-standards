use std::time::SystemTime;

#[must_use]
pub fn stamp() -> SystemTime {
    SystemTime::now()
}
