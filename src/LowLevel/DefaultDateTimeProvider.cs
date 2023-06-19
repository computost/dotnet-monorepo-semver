namespace LowLevel;
public class DefaultDateTimeProvider : IDateTimeProvider
{
    public DateTime Now => DateTime.Now;
}
