//! Positive fixture: idiomatic code that satisfies every Engineering Standards lint.

use std::fmt;
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
    pub fn get(self) -> u32 {
        self.0
    }
}

/// A mass in grams (DOMAIN-001).
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Default)]
pub struct Grams(u64);

impl Grams {
    #[must_use]
    pub fn new(value: u64) -> Self {
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
pub fn describe(state: LotState) -> &'static str {
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
    fn describe_covers_every_state() {
        assert_eq!(describe(LotState::Received), "received");
        assert_eq!(describe(LotState::Inspected), "inspected");
        assert_eq!(describe(LotState::Shipped), "shipped");
    }
}
