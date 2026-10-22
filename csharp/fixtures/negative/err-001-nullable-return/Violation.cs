namespace Fixture;

public static class Violation
{
    public static string Find(Dictionary<string, string> map, string key) => map.GetValueOrDefault(key);
}
