namespace Fixture;

public sealed record UnpaidOrder(decimal Weight)
{
    public PaidOrder Pay() => new(Weight);
}

public sealed record PaidOrder(decimal Weight)
{
    public ShippedOrder Ship() => new(Weight);
}

public sealed record ShippedOrder(decimal Weight);

public static class Violation
{
    public static ShippedOrder ShipWithoutPaying(UnpaidOrder order) => order.Ship();
}
