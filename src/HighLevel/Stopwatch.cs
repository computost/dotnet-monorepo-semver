using LowLevel;

namespace HighLevel;
public class Stopwatch
{
    private readonly IDateTimeProvider _dateTimeProvider;

    public Stopwatch(IDateTimeProvider dateTimeProvider)
    {
        _dateTimeProvider = dateTimeProvider;
    }
    
    public async Task<TimeSpan> Track(Task task)
    {
        var start = _dateTimeProvider.Now;
        await task;
        return _dateTimeProvider.Now - start;
    }
}
