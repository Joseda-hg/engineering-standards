use std::future::{Ready, ready};

async fn work(input: Ready<u32>) -> u32 {
    input.await
}

pub fn start() {
    work(ready(42));
}
