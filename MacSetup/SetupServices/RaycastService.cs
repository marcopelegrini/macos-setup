using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class RaycastService(PromptService prompts, ILogger<RaycastService> logger) : ISetupBackupService
{
    public string CommandName => "raycast";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Restore Raycast Backup";

    public Task SetupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("\n━━━ 🔦 Restore Raycast Backup");
        logger.LogInformation("📍 Raycast > Preferences > Advanced > Import Settings");
        prompts.Pause("Press Enter when done...");
        logger.LogInformation("✅ Raycast restored.");
        return Task.CompletedTask;
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("\n━━━ 🔦 Backup Raycast");
        logger.LogInformation("Open Raycast.");
        logger.LogInformation("Go to Preferences > Advanced.");
        logger.LogInformation("Click 'Export Settings'.");
        logger.LogInformation("Save the backup file.");
        prompts.Pause("Press Enter when done...");
        logger.LogInformation("✅ Raycast backup confirmed.");
        return Task.CompletedTask;
    }
}
