namespace Fixture;

public static class Violation
{
    public static void Quit(int code)
    {
        if (code == 1)
        {
            Environment.Exit(code);
        }

        if (code == 2)
        {
            Environment.FailFast("fatal");
        }

        Environment.FailFast("fatal", new InvalidOperationException());
    }
}
