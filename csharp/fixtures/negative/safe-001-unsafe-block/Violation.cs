namespace Fixture;

public static class Violation
{
    public static unsafe int Read(int* pointer) => *pointer;
}
