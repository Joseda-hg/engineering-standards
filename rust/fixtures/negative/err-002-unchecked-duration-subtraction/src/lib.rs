use std::time::{Duration, Instant};

#[must_use]
pub fn earlier(at: Instant, by: Duration) -> Instant {
    at - by
}
