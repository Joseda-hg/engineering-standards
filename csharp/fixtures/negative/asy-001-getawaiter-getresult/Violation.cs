namespace Fixture;

public static class Violation
{
    // One call per awaiter type: every BannedSymbols.txt GetResult entry must fire (expected count = 8).
    public static int Block(Task task, Task<int> typed, ValueTask value, ValueTask<int> typedValue)
    {
        ArgumentNullException.ThrowIfNull(task);
        ArgumentNullException.ThrowIfNull(typed);

        task.GetAwaiter().GetResult();
        value.GetAwaiter().GetResult();
        task.ConfigureAwait(false).GetAwaiter().GetResult();
        value.ConfigureAwait(false).GetAwaiter().GetResult();

        return typed.GetAwaiter().GetResult()
            + typedValue.GetAwaiter().GetResult()
            + typed.ConfigureAwait(false).GetAwaiter().GetResult()
            + typedValue.ConfigureAwait(false).GetAwaiter().GetResult();
    }
}
