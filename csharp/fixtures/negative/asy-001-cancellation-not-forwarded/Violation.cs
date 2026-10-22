namespace Fixture;

public static class Violation
{
    public static async Task PauseAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await Task.Delay(10).ConfigureAwait(false);
    }
}
