pub enum Light {
    Red,
    Green,
}

#[must_use]
pub const fn may_pass(light: &Light) -> bool {
    use Light::*;
    match light {
        Red => false,
        Green => true,
    }
}
