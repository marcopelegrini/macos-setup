namespace MacSetup.SetupServices;

using Microsoft.Extensions.Logging;

internal sealed class MackupService(AppPaths paths, CommandRunner commandRunner, ILogger<MackupService> logger) : ISetupBackupService
{
    public string CommandName => "mackup";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Restore Mackup Backups";

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("━━━ 🗂️ Restore Mackup Backups");
        var hasMackup = await commandRunner.CaptureAsync("/usr/bin/which", ["mackup"], cancellationToken) is not null;
        var mackupCfg = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".mackup.cfg");
        if (!Directory.Exists(paths.MackupDirectory) || !hasMackup || !File.Exists(mackupCfg))
        {
            logger.LogWarning("⚠️ Skipping Mackup restore - prerequisites not met");
            return;
        }

        await commandRunner.RunAsync("mackup", ["restore"], cancellationToken: cancellationToken);
        logger.LogInformation("✅ Mackup restored");
    }

    public async Task BackupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("━━━ 🗃️ Backup Mackup");
        var hasMackup = await commandRunner.CaptureAsync("/usr/bin/which", ["mackup"], cancellationToken) is not null;
        var mackupCfg = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".mackup.cfg");
        if (!hasMackup || !File.Exists(mackupCfg))
        {
            logger.LogWarning("⚠️ Mackup is not installed or config not found at ~/.mackup.cfg");
            throw new InvalidOperationException("Mackup backup prerequisites are not met.");
        }

        await commandRunner.RunAsync("mackup", ["backup", "--force"], cancellationToken: cancellationToken);
        logger.LogInformation("✅ Mackup backup complete");
        logger.LogInformation("📁 Mackup files were backed up to the location configured in ~/.mackup.cfg");
        logger.LogWarning("📌 Remember to store the mackup folder somewhere safe");
    }
}
