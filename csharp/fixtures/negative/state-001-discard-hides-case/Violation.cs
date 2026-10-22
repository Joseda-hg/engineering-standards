namespace Fixture;

public enum Light
{
    Red,
    Amber,
    Green,
}

public static class Violation
{
    public static bool MayPass(Light light) => light switch
    {
        Light.Red => false,
        _ => true,
    };
}
