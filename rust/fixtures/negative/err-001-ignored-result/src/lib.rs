fn save(value: u32) -> Result<(), String> {
    if value == 0 {
        return Err("zero".to_owned());
    }
    Ok(())
}

pub fn run(value: u32) {
    save(value);
}
