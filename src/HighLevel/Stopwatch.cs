using System;
using System.Threading.Tasks;
using Internal;
using LowLevel;

namespace HighLevel;
public class Stopwatch
{
    private readonly IDateTimeProvider _dateTimeProvider;

    public Stopwatch(IDateTimeProvider dateTimeProvider)
    {
        _dateTimeProvider = dateTimeProvider;
    }
    
    public Task<TimeSpan> Track(Func<Task> task)
    {
        var start = _dateTimeProvider.Now;
        return task.Invoke().Then(() => _dateTimeProvider.Now - start);
    }
}
