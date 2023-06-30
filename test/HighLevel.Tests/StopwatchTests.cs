using System;
using System.Threading.Tasks;
using FluentAssertions;
using FluentAssertions.Extensions;
using LowLevel;
using Xunit;

namespace HighLevel.Tests;

public class StopwatchTests
{
    [Fact]
    public async Task TracksTime()
    {
        var now = new DateTime(2000, 1, 1, 12, 0, 0);
        var dateTimeProvider = new MutableDateTimeProvider(now, now.Date);
        var stopwatch = new Stopwatch(dateTimeProvider);

        var timeSpan = await stopwatch.Track(() =>
        {
            dateTimeProvider.Now = now.AddHours(1);
            return Task.CompletedTask;
        });

        timeSpan.Should().Be(1.Hours());
    }
}
