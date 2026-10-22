namespace Fixture;

public static class Violation
{
    public static int Read(Task<int> task)
    {
        ArgumentNullException.ThrowIfNull(task);
        return task.Result;
    }

    public static int ReadValue(ValueTask<int> task) => task.Result;
}
