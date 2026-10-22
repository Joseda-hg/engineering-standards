pub enum Light {
    Red,
    Amber,
    Green,
}

#[must_use]
pub fn name(light: &Light) -> &'static str {
    match light {
        Light::Red => "red",
        Light::Amber => "amber",
    }
}
