namespace Fixture;

public static class Violation
{
#pragma warning disable CA1031
    public static void Swallow() { }
#pragma warning restore CA1031
}
