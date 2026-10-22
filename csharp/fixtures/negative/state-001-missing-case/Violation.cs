namespace Fixture;

public enum Light
{
    Red,
    Amber,
    Green,
}

public static class Violation
{
    public static string Name(Light light) => light switch
    {
        Light.Red => "red",
        Light.Amber => "amber",
    };
}
