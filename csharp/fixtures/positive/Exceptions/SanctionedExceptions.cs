using System.Diagnostics.CodeAnalysis;

namespace Exceptions;

/// <summary>The single adapter allowed to read the wall clock (API-001 exception).</summary>
public static class WallClock
{
#pragma warning disable RS0030 // API-001: sanctioned wall-clock adapter, reviewed in DEMO-1
    public static DateTimeOffset UtcNow() => DateTimeOffset.UtcNow;
#pragma warning restore RS0030
}

/// <summary>Top-level boundary that converts every failure into a result (ERR-001 exception).</summary>
public static class Boundary
{
    [SuppressMessage(
        "Design",
        "CA1031:Do not catch general exception types",
        Justification = "ERR-001: process boundary converts all failures, see DEMO-2")]
    public static bool TryRun(Action action)
    {
        ArgumentNullException.ThrowIfNull(action);
        try
        {
            action();
            return true;
        }
        catch (Exception)
        {
            return false;
        }
    }
}

/// <summary>Unsafe code allowed by EngineeringStandardsUnsafeJustification (SAFE-001 exception).</summary>
public static class Interop
{
    public static unsafe int ReadFirst(ReadOnlySpan<int> values)
    {
        fixed (int* pointer = values)
        {
            return values.IsEmpty ? 0 : *pointer;
        }
    }
}
