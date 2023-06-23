namespace LowLevel;
public class ConstantDateTimeProvider : IDateTimeProvider
{
    public ConstantDateTimeProvider(DateTime date)
        => Now = date;

    public DateTime Now { get; }
}
