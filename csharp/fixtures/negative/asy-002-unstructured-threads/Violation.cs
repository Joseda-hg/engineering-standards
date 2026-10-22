namespace Fixture;

public static class Violation
{
    public static void Start(IThreadPoolWorkItem item)
    {
        _ = new Thread(Work);
        _ = new Thread(Work, 1024);
        _ = new Thread(WorkWithState);
        _ = new Thread(WorkWithState, 1024);
        _ = ThreadPool.QueueUserWorkItem(WorkWithState);
        _ = ThreadPool.QueueUserWorkItem(WorkWithState, null);
        _ = ThreadPool.QueueUserWorkItem(WorkWithInt, 1, preferLocal: false);
        _ = ThreadPool.UnsafeQueueUserWorkItem(WorkWithState, null);
        _ = ThreadPool.UnsafeQueueUserWorkItem(WorkWithInt, 1, preferLocal: false);
        _ = ThreadPool.UnsafeQueueUserWorkItem(item, preferLocal: false);
    }

    private static void Work()
    {
    }

    private static void WorkWithState(object? state)
    {
    }

    private static void WorkWithInt(int state)
    {
    }
}
