namespace Inventory;

/// <summary>
/// Typestate (MODEL-001): each order state is its own type and exposes only its valid transitions,
/// so shipping an unpaid order does not compile.
/// </summary>
public sealed record UnpaidOrder(Kilos Weight)
{
    public PaidOrder Pay() => new(Weight);
}

/// <summary>An order that has been paid and can be shipped.</summary>
public sealed record PaidOrder(Kilos Weight)
{
    public ShippedOrder Ship() => new(Weight);
}

/// <summary>Terminal state: no further transitions exist.</summary>
public sealed record ShippedOrder(Kilos Weight);
