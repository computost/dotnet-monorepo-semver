using System;
using System.Threading.Tasks;
using LowLevel;

namespace HighLevel;
public class Stopwatch
{
    private readonly IDateTimeProvider _dateTimeProvider;

    public Stopwatch(IDateTimeProvider dateTimeProvider)
    {
        _dateTimeProvider = dateTimeProvider;
    }
    
    public async Task<TimeSpan> Track(Func<Task> task)
    {
        var start = _dateTimeProvider.Now;
        await task.Invoke();
        return _dateTimeProvider.Now - start;
    }
}
