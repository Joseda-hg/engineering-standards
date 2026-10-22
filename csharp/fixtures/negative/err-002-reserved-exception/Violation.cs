namespace Fixture;

public static class Violation
{
    public static int Positive(int value) => value > 0 ? value : throw new Exception("not positive");
}
