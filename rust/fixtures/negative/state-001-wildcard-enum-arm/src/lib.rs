pub enum Light {
    Red,
    Amber,
    Green,
}

#[must_use]
pub const fn instruction(light: &Light) -> &'static str {
    match light {
        Light::Red => "stop",
        _ => "go",
    }
}
