namespace Fixture;

public static class Violation
{
    public static int Later(int value) => value switch
    {
        0 => throw new NotImplementedException(),
        1 => throw new NotImplementedException("soon"),
        2 => throw new NotImplementedException("soon", new InvalidOperationException()),
        _ => value,
    };
}
