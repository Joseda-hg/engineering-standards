namespace Fixture;

public static class Violation
{
    public static int Block(Task<int> task, Task other)
    {
        ArgumentNullException.ThrowIfNull(task);
        ArgumentNullException.ThrowIfNull(other);
        other.GetAwaiter().GetResult();
        return task.GetAwaiter().GetResult();
    }
}
