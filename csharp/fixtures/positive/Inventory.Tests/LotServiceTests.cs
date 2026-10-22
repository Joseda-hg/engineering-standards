using Microsoft.Extensions.Time.Testing;

namespace Inventory.Tests;

public sealed class LotServiceTests
{
    [Fact]
    public void ReceiveUsesInjectedClock()
    {
        var now = new DateTimeOffset(2026, 1, 2, 3, 4, 5, TimeSpan.Zero);
        var service = new LotService(new FakeTimeProvider(now));

        var lot = service.Receive(new LotId(7), new Kilos(12.5m));

        Assert.Equal(now, lot.ReceivedAt);
        Assert.Equal(LotState.Received, lot.State);
    }

    [Theory]
    [InlineData(LotState.Received, "received")]
    [InlineData(LotState.Inspected, "inspected")]
    [InlineData(LotState.Shipped, "shipped")]
    public void DescribeCoversEveryState(LotState state, string expected) =>
        Assert.Equal(expected, LotService.Describe(state));

    [Theory]
    [InlineData("42", 42)]
    [InlineData("0", null)]
    [InlineData("abc", null)]
    [InlineData(null, null)]
    public void TryParseIdMakesAbsenceExplicit(string? text, int? expected) =>
        Assert.Equal(expected, LotService.TryParseId(text)?.Value);

    [Fact]
    public async Task TotalWeightSumsAllLots()
    {
        var at = DateTimeOffset.UnixEpoch;
        Lot[] lots =
        [
            new(new LotId(1), new Kilos(1.5m), LotState.Received, at),
            new(new LotId(2), new Kilos(2.5m), LotState.Shipped, at),
        ];

        var total = await LotService.TotalWeightAsync(lots.ToAsyncEnumerable(), TestContext.Current.CancellationToken);

        Assert.Equal(new Kilos(4m), total);
    }
}
