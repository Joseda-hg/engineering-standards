namespace Fixture;

public static class Violation
{
    // One call per overload: every BannedSymbols.txt entry must fire (expected count = 18).
    public static void Block(Task task, Task[] tasks)
    {
        ArgumentNullException.ThrowIfNull(task);
        var timeout = TimeSpan.FromSeconds(1);
        var token = CancellationToken.None;

        task.Wait();
        _ = task.Wait(timeout);
        _ = task.Wait(timeout, token);
        task.Wait(token);
        _ = task.Wait(1000);
        _ = task.Wait(1000, token);

        Task.WaitAll(tasks);
        Task.WaitAll(task, task);
        _ = Task.WaitAll(tasks, timeout);
        _ = Task.WaitAll(tasks, 1000);
        Task.WaitAll(tasks, token);
        _ = Task.WaitAll(tasks, 1000, token);
        Task.WaitAll(new List<Task> { task }, token);

        _ = Task.WaitAny(tasks);
        _ = Task.WaitAny(tasks, timeout);
        _ = Task.WaitAny(tasks, token);
        _ = Task.WaitAny(tasks, 1000);
        _ = Task.WaitAny(tasks, 1000, token);
    }
}
