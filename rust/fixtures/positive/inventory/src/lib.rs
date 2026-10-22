//! Positive fixture: idiomatic code that satisfies every Engineering Standards lint.
// SAFE-001: this crate needs no unsafe code, so it is forbidden outright (no #[expect] possible).
#![forbid(unsafe_code)]

use std::fmt;
use std::marker::PhantomData;
use std::num::NonZeroUsize;
use std::ops::Add;
use std::time::SystemTime;

/// Identity of a lot. A distinct type so it cannot be confused with other integers (DOMAIN-001).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct LotId(u32);

impl LotId {
    /// Returns `None` for zero, which is not a valid identity (ERR-001).
    #[must_use]
    pub fn new(value: u32) -> Option<Self> {
        (value > 0).then_some(Self(value))
    }

    #[must_use]
    pub const fn get(self) -> u32 {
        self.0
    }
}

/// A mass in grams (DOMAIN-001).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Default)]
pub struct Grams(u64);

impl Grams {
    #[must_use]
    pub const fn new(value: u64) -> Self {
        Self(value)
    }
}

impl Add for Grams {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self(self.0.saturating_add(other.0))
    }
}

/// Closed set of lot states (STATE-001).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LotState {
    Received,
    Inspected,
    Shipped,
}

/// Exhaustive match without a wildcard arm (STATE-001).
#[must_use]
pub const fn describe(state: LotState) -> &'static str {
    match state {
        LotState::Received => "received",
        LotState::Inspected => "inspected",
        LotState::Shipped => "shipped",
    }
}

/// Why a lot identifier could not be parsed (ERR-001).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ParseLotIdError {
    NotANumber,
    Zero,
}

impl fmt::Display for ParseLotIdError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::NotANumber => f.write_str("lot id is not a number"),
            Self::Zero => f.write_str("lot id must be positive"),
        }
    }
}

impl std::error::Error for ParseLotIdError {}

/// Failure is part of the signature (ERR-001).
///
/// ```
/// use inventory::{parse_lot_id, ParseLotIdError};
///
/// assert_eq!(parse_lot_id(" 7 ").map(|id| id.get()), Ok(7));
/// assert_eq!(parse_lot_id("0"), Err(ParseLotIdError::Zero));
/// ```
///
/// # Errors
///
/// Returns [`ParseLotIdError`] when `text` is not a positive integer.
pub fn parse_lot_id(text: &str) -> Result<LotId, ParseLotIdError> {
    let value: u32 = text
        .trim()
        .parse()
        .map_err(|_| ParseLotIdError::NotANumber)?;
    LotId::new(value).ok_or(ParseLotIdError::Zero)
}

/// Source of time, injected into domain logic (API-001).
pub trait Clock {
    fn now(&self) -> SystemTime;
}

/// The single sanctioned wall-clock adapter.
#[derive(Debug, Default, Clone, Copy)]
pub struct SystemClock;

impl Clock for SystemClock {
    #[expect(
        clippy::disallowed_methods,
        reason = "API-001: the only adapter allowed to read the wall clock"
    )]
    fn now(&self) -> SystemTime {
        SystemTime::now()
    }
}

/// A lot of goods.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lot {
    pub id: LotId,
    pub weight: Grams,
    pub state: LotState,
    pub received_at: SystemTime,
}

/// Creates a lot stamped by the injected clock.
#[must_use]
pub fn receive(clock: &impl Clock, id: LotId, weight: Grams) -> Lot {
    Lot {
        id,
        weight,
        state: LotState::Received,
        received_at: clock.now(),
    }
}

/// Total weight of the given lots.
#[must_use]
pub fn total_weight(lots: &[Lot]) -> Grams {
    lots.iter()
        .map(|lot| lot.weight)
        .fold(Grams::default(), Add::add)
}

/// Total weight computed on scoped threads (ASY-002).
///
/// The workers borrow `lots` directly, with no `'static` bound or `Arc`, because
/// `std::thread::scope` joins them before returning. Returns `None` if a worker panicked,
/// instead of hiding the failure.
#[must_use]
pub fn parallel_total_weight(lots: &[Lot], chunk_size: NonZeroUsize) -> Option<Grams> {
    std::thread::scope(|scope| {
        #[expect(
            clippy::needless_collect,
            reason = "IDIOM-001: nursery false positive - collecting spawns every worker before the first join; a lazy chain would run them one at a time"
        )]
        let workers: Vec<_> = lots
            .chunks(chunk_size.get())
            .map(|chunk| scope.spawn(move || total_weight(chunk)))
            .collect();
        workers
            .into_iter()
            .map(|worker| worker.join().ok())
            .try_fold(Grams::default(), |sum, part| {
                part.map(|weight| Add::add(sum, weight))
            })
    })
}

/// Typestate (MODEL-001): an order's state is part of its type, so shipping an unpaid order does
/// not compile. Each transition consumes the previous state.
///
/// ```compile_fail
/// use inventory::{Grams, Order};
/// let order = Order::new(Grams::new(1));
/// order.ship(); // error: no method `ship` on `Order<Unpaid>`
/// ```
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Order<State> {
    weight: Grams,
    state: PhantomData<State>,
}

/// Order state: created, not paid.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Unpaid;
/// Order state: paid, not shipped.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Paid;
/// Order state: shipped (terminal).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Shipped;

impl Order<Unpaid> {
    #[must_use]
    pub const fn new(weight: Grams) -> Self {
        Self {
            weight,
            state: PhantomData,
        }
    }

    #[must_use]
    pub const fn pay(self) -> Order<Paid> {
        Order {
            weight: self.weight,
            state: PhantomData,
        }
    }
}

impl Order<Paid> {
    #[must_use]
    pub const fn ship(self) -> Order<Shipped> {
        Order {
            weight: self.weight,
            state: PhantomData,
        }
    }
}

impl<State> Order<State> {
    #[must_use]
    pub const fn weight(&self) -> Grams {
        self.weight
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_rejects_zero_and_garbage() {
        assert_eq!(parse_lot_id("0"), Err(ParseLotIdError::Zero));
        assert_eq!(parse_lot_id("abc"), Err(ParseLotIdError::NotANumber));
        assert_eq!(parse_lot_id(" 42 ").unwrap().get(), 42);
    }

    #[test]
    fn parallel_total_matches_sequential() {
        let clock = SystemClock;
        let lots: Vec<Lot> = (1..=10)
            .map(|n| receive(&clock, LotId::new(n).unwrap(), Grams::new(u64::from(n))))
            .collect();
        let chunk = NonZeroUsize::new(3).unwrap();

        assert_eq!(
            parallel_total_weight(&lots, chunk),
            Some(total_weight(&lots))
        );
    }

    #[test]
    fn order_moves_through_its_states() {
        let shipped = Order::new(Grams::new(5)).pay().ship();

        assert_eq!(shipped.weight(), Grams::new(5));
    }

    proptest::proptest! {
        // TEST-001: properties over generated input, shrunk to a minimal failing case.
        #[test]
        fn parse_round_trips_every_positive_id(value in 1..=u32::MAX) {
            proptest::prop_assert_eq!(parse_lot_id(&value.to_string()).map(LotId::get), Ok(value));
        }

        #[test]
        fn parse_never_panics(text in ".*") {
            let _ = parse_lot_id(&text);
        }
    }

    #[test]
    fn describe_covers_every_state() {
        assert_eq!(describe(LotState::Received), "received");
        assert_eq!(describe(LotState::Inspected), "inspected");
        assert_eq!(describe(LotState::Shipped), "shipped");
    }
}
