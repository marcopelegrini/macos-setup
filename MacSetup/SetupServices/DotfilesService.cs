using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class DotfilesService(AppPaths paths, PromptService prompts, ILogger<DotfilesService> logger) : ISetupBackupService
{
    public string CommandName => "dotfiles";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Install Dotfiles";

    public Task SetupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("\n━━━ 🔗 Install Dotfiles");

        if (!Directory.Exists(paths.DotfilesDirectory))
        {
            logger.LogWarning("⚠️ Dotfiles directory not found at: {DotfilesDirectory}", paths.DotfilesDirectory);
            return Task.CompletedTask;
        }

        foreach (var entry in Directory.EnumerateFileSystemEntries(paths.DotfilesDirectory).OrderBy(Path.GetFileName))
        {
            var name = Path.GetFileName(entry);
            if (string.IsNullOrEmpty(name) || !name.StartsWith('.') || name == ".DS_Store")
            {
                continue;
            }

            var target = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), name);
            if (File.Exists(target) || Directory.Exists(target))
            {
                if (!prompts.Confirm($"{target} already exists. Remove it?"))
                {
                    logger.LogInformation("Skipping {Name}", name);
                    continue;
                }

                if (Directory.Exists(target) && !File.GetAttributes(target).HasFlag(FileAttributes.ReparsePoint))
                {
                    throw new InvalidOperationException($"Refusing to remove directory: {target}");
                }

                File.Delete(target);
            }

            File.CreateSymbolicLink(target, entry);
            logger.LogInformation("Linked {Name}", name);
        }

        logger.LogInformation("✅ Dotfiles complete.");
        return Task.CompletedTask;
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("\n━━━ 🔗 Backup Dotfiles");
        logger.LogInformation("Skipping dotfiles backup: no backup operation is defined.");
        return Task.CompletedTask;
    }
}
