namespace Fixture;

public static class Violation
{
    public static void Block(Task task)
    {
        ArgumentNullException.ThrowIfNull(task);
        task.Wait();
        _ = task.Wait(TimeSpan.FromSeconds(1));
        Task.WaitAll(task);
        _ = Task.WaitAny(task);
    }
}
