namespace Fixture;

public sealed class Violation(int seed)
{
    private int _seed = seed;

    public int Seed => _seed;
}
