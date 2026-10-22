namespace Fixture;

public static class Violation
{
    public static int HomeLength()
    {
        string? home = Environment.GetEnvironmentVariable("HOME");
        return home.Length;
    }
}
