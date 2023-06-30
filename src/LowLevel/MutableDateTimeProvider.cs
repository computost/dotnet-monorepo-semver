using System;

namespace LowLevel;

public class MutableDateTimeProvider : IDateTimeProvider
{
    public MutableDateTimeProvider(DateTime now, DateTime today)
    {
        Now = now;
        Today = today;
    }

    public DateTime Now { get; set; }

    public DateTime Today { get; set; }
}