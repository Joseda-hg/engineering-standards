using System.Diagnostics.CodeAnalysis;

namespace Fixture;

public static class Violation
{
    [SuppressMessage("Design", "CA1031:Do not catch general exception types")]
    public static void Swallow() { }
}
