using System.Globalization;
using CsCheck;

namespace Inventory.Tests;

/// <summary>TEST-001: properties over generated input, shrunk to a minimal failing case.</summary>
public sealed class PropertyTests
{
    [Fact]
    public void TryParseIdRoundTripsEveryPositiveId() =>
        Gen.Int[1, int.MaxValue].Sample(value =>
            LotService.TryParseId(value.ToString(CultureInfo.InvariantCulture))?.Value == value);

    [Fact]
    public void TryParseIdNeverThrows() =>
        Gen.String.Sample(text => LotService.TryParseId(text) is null or { Value: > 0 });

    [Fact]
    public void OrderMovesThroughItsStates() =>
        Assert.Equal(new Kilos(5m), new UnpaidOrder(new Kilos(5m)).Pay().Ship().Weight);
}
