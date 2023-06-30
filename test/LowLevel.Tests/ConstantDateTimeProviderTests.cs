using System;
using FluentAssertions;
using Xunit;

namespace LowLevel.Tests;

public class ConstantDateTimeProviderTests
{
    [Fact]
    public void TracksNowAndToday()
    {
        var now = new DateTime(2000, 1, 1, 12, 0, 0);
        var today = now.Date;
        
        var provider = new ConstantDateTimeProvider(now, today);

        provider.Now.Should().Be(now);
        provider.Today.Should().Be(today);
    }
}