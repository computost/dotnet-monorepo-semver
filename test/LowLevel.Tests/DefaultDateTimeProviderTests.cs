using System;
using FluentAssertions;
using FluentAssertions.Extensions;
using Xunit;

namespace LowLevel.Tests;

public class DefaultDateTimeProviderTests
{
    [Fact]
    public void ProvidesNowAndToday()
    {
        var provider = new DefaultDateTimeProvider();

        provider.Now.Should().BeWithin(50.Milliseconds()).Before(DateTime.Now);
        provider.Today.Should().Be(DateTime.Today);
    }
}