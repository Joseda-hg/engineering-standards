namespace Fixture;

public static class Violation
{
    public static IReadOnlyList<DateTimeOffset> Stamps() =>
    [
        DateTime.Now,
        DateTime.UtcNow,
        DateTime.Today,
        DateTimeOffset.Now,
        DateTimeOffset.UtcNow,
    ];
}
