namespace Inventory;

/// <summary>Identity of a lot. Distinct type so it cannot be confused with other integers (DOMAIN-001).</summary>
public readonly record struct LotId(int Value);

/// <summary>A mass in kilograms (DOMAIN-001).</summary>
public readonly record struct Kilos(decimal Value)
{
    public static Kilos operator +(Kilos left, Kilos right) => new(left.Value + right.Value);

    public static Kilos Add(Kilos left, Kilos right) => left + right;
}

/// <summary>Closed set of lot states (STATE-001).</summary>
public enum LotState
{
    Received,
    Inspected,
    Shipped,
}

/// <summary>A lot of goods.</summary>
public sealed record Lot(LotId Id, Kilos Weight, LotState State, DateTimeOffset ReceivedAt);
