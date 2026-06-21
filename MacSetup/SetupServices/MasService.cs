using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class MasService(CommandRunner commandRunner, PromptService prompts, ILogger<MasService> logger) : ISetupBackupService
{
    public string CommandName => "mas";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Install App Store Apps";

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("\n━━━ 🛍️ App Store Apps");
        var hasMas = await commandRunner.CaptureAsync("/usr/bin/which", ["mas"], cancellationToken) is not null;
        if (!hasMas)
        {
            logger.LogWarning("⚠️ mas-cli is not installed. Skipping App Store apps.");
            return;
        }

        logger.LogInformation("📲 Open the App Store and sign in with your Apple ID.");
        prompts.Pause("Press Enter when signed in...");
        await commandRunner.RunAsync("mas", ["install", "1561788435"], cancellationToken: cancellationToken);
        await commandRunner.RunAsync("mas", ["install", "1352778147"], cancellationToken: cancellationToken);
        logger.LogInformation("✅ Mac App Store apps installed.");
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("\n━━━ 🛍️ Backup App Store Apps");
        logger.LogInformation("Skipping App Store backup: no backup operation is defined.");
        return Task.CompletedTask;
    }
}
