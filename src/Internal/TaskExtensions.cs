namespace Internal;

public static class TaskExtensions
{
    public static async Task<TOutput> Then<TOutput>(this Task before, Func<TOutput> after)
    {
        await before;
        return after.Invoke();
    }
}
