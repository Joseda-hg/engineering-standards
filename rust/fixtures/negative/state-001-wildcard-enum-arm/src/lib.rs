pub enum Light {
    Red,
    Amber,
    Green,
}

#[must_use]
pub fn instruction(light: &Light) -> &'static str {
    match light {
        Light::Red => "stop",
        _ => "go",
    }
}
