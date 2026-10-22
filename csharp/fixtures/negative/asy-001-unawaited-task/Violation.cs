namespace Fixture;

public static class Violation
{
    public static async Task RunAsync(CancellationToken cancellationToken)
    {
        Task.Delay(10, cancellationToken);
        await Task.Delay(10, cancellationToken).ConfigureAwait(false);
    }
}
