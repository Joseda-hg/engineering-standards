use std::time::{Duration, SystemTime};

use inventory::{Clock, Grams, LotId, LotState, receive, total_weight};

struct FixedClock(SystemTime);

impl Clock for FixedClock {
    fn now(&self) -> SystemTime {
        self.0
    }
}

#[test]
fn receive_uses_injected_clock() {
    let at = SystemTime::UNIX_EPOCH + Duration::from_secs(1_700_000_000);
    let id = LotId::new(7).expect("7 is a valid id");

    let lot = receive(&FixedClock(at), id, Grams::new(12_500));

    assert_eq!(lot.received_at, at);
    assert_eq!(lot.state, LotState::Received);
}

#[test]
fn total_weight_sums_all_lots() {
    let clock = FixedClock(SystemTime::UNIX_EPOCH);
    let lots = [
        receive(&clock, LotId::new(1).unwrap(), Grams::new(1_500)),
        receive(&clock, LotId::new(2).unwrap(), Grams::new(2_500)),
    ];

    assert_eq!(total_weight(&lots), Grams::new(4_000));
}
