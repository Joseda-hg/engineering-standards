using System.Globalization;

namespace Inventory;

/// <summary>Domain operations on lots.</summary>
public sealed class LotService(TimeProvider clock)
{
    private readonly TimeProvider _clock = clock;

    /// <summary>Creates a lot stamped with the injected clock (API-001).</summary>
    public Lot Receive(LotId id, Kilos weight) => new(id, weight, LotState.Received, _clock.GetUtcNow());

    /// <summary>
    /// Every named state is listed (STATE-001); the discard only rejects out-of-range numeric values.
    /// </summary>
    public static string Describe(LotState state) => state switch
    {
        LotState.Received => "received",
        LotState.Inspected => "inspected",
        LotState.Shipped => "shipped",
        _ => throw new ArgumentOutOfRangeException(nameof(state), state, "Unknown lot state."),
    };

    /// <summary>Absence is explicit in the signature (ERR-001).</summary>
    public static LotId? TryParseId(string? text) =>
        int.TryParse(text, NumberStyles.Integer, CultureInfo.InvariantCulture, out var value) && value > 0
            ? new LotId(value)
            : null;

    /// <summary>Async all the way down with cancellation (ASY-001).</summary>
    public static async Task<Kilos> TotalWeightAsync(
        IAsyncEnumerable<Lot> lots,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(lots);
        var total = new Kilos(0m);
        await foreach (var lot in lots.WithCancellation(cancellationToken).ConfigureAwait(false))
        {
            total += lot.Weight;
        }

        return total;
    }
}
