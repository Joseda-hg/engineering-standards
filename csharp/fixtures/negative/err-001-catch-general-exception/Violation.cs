namespace Fixture;

public static class Violation
{
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
