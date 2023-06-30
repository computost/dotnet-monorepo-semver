using System;
using FluentAssertions;
using Xunit;

namespace LowLevel.Tests;

public class MutableDateTimeProviderTests
{
    [Fact]
    public void ProvidesMutableNowAndToday()
    {
        var now = new DateTime(2000, 1, 1, 12, 0, 0);
        var today = now.Date;
        
        var provider = new MutableDateTimeProvider(now, today);
        provider.Now.Should().Be(now);
        provider.Today.Should().Be(today);

        var later = now.AddHours(1);
        var tomorrow = today.AddHours(1);
        
        provider.Now = later;
        provider.Today = tomorrow;

        provider.Now.Should().Be(later);
        provider.Today.Should().Be(tomorrow);
    }
}
