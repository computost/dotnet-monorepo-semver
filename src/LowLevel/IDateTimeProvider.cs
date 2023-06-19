namespace LowLevel;

public interface IDateTimeProvider
{
    /// <summary>
    /// The current date and time.
    /// </summary>
    DateTime Now { get; }
}