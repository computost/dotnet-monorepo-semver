using System;

namespace LowLevel;
public class ConstantDateTimeProvider : IDateTimeProvider
{
    public ConstantDateTimeProvider(DateTime now, DateTime today)
    {
        Now = now;
        Today = today;
    }

    public DateTime Now { get; }

    public DateTime Today { get; }
}
