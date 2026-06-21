using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class PromptService(ILogger<PromptService> logger)
{
    public bool Confirm(string prompt)
    {
        Console.Write($"{prompt} [y/N]: ");
        var response = Console.ReadLine()?.Trim();
        return string.Equals(response, "y", StringComparison.OrdinalIgnoreCase);
    }

    public void Pause(string prompt)
    {
        Console.Write(prompt);
        Console.ReadLine();
    }

    public bool SkipStep(string stepName, int timeoutSeconds = 5)
    {
        logger.LogWarning("Press any key within {TimeoutSeconds} seconds to skip this step...", timeoutSeconds);

        try
        {
            var timeoutAt = DateTime.UtcNow.AddSeconds(timeoutSeconds);
            while (DateTime.UtcNow < timeoutAt)
            {
                if (Console.KeyAvailable)
                {
                    Console.ReadKey(intercept: true);
                    logger.LogWarning("Skipping: {StepName}", stepName);
                    return true;
                }

                Thread.Sleep(100);
            }
        }
        catch (InvalidOperationException)
        {
            return false;
        }

        return false;
    }
}
