namespace Fixture;

public enum Light
{
    Red,
    Amber,
    Green,
}

public static class Violation
{
    public static string Instruction(Light light)
    {
        switch (light)
        {
            case Light.Red:
                return "stop";
            default:
                return "go";
        }
    }
}
