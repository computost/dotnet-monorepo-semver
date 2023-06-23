namespace LowLevel;

public interface IDateTimeProvider
{
    /// <summary>
    /// The current date and time.
    /// </summary>
    DateTime Now { get; }

    /// <summary>
    /// The current date.
    /// </summary>
    DateTime Today { get; }
}