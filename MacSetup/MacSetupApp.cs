using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class MacSetupApp(
    ILogger<MacSetupApp> logger,
    PromptService promptService,
    IEnumerable<ISetupBackupService> services)
{
    private const string BannerLine = "════════════════════════════════════════════";

    public async Task<int> RunAsync(string[] args, CancellationToken cancellationToken)
    {
        CliOptions options;
        try
        {
            options = CliParser.Parse(args);
        }
        catch (ArgumentException ex)
        {
            logger.LogError(ex.Message);
            Console.WriteLine();
            Console.WriteLine(CliOptions.HelpText);
            return 1;
        }

        if (options.Command == "help")
        {
            Console.WriteLine(CliOptions.HelpText);
            return 0;
        }

        try
        {
            switch (options.Command)
            {
                case "setup":
                    await SetupAsync(cancellationToken);
                    break;
                case "backup":
                    await BackupAsync(cancellationToken);
                    break;
                default:
                    var service = services.FirstOrDefault(candidate =>
                        string.Equals(candidate.CommandName, options.Command, StringComparison.OrdinalIgnoreCase));
                    if (service is null)
                    {
                        logger.LogError("Unknown command: {Command}", options.Command);
                        Console.WriteLine();
                        Console.WriteLine(CliOptions.HelpText);
                        return 1;
                    }

                    if (options.Action == "backup")
                    {
                        await service.BackupAsync(cancellationToken);
                    }
                    else
                    {
                        await service.SetupAsync(cancellationToken);
                    }

                    break;
            }

            return 0;
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Command failed");
            return 1;
        }
    }

    private async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("🚀 {BannerLine}", BannerLine);
        logger.LogInformation("🛠️  macOS Setup Wizard");
        logger.LogInformation("📦 Includes: sudo, dotfiles, Homebrew, App Store apps, Dock, Mackup, Raycast, macOS settings");
        logger.LogWarning("🔐 Sudo may be requested multiple times during this run.");
        logger.LogInformation("🚀 {BannerLine}", BannerLine);

        if (!promptService.Confirm("Continue with setup?"))
        {
            logger.LogWarning("🛑 Setup cancelled.");
            return;
        }

        foreach (var service in services.Where(candidate => candidate.IncludeInWorkflow))
        {
            await RunStepAsync(service.GetStepName(), () => service.SetupAsync(cancellationToken));
        }

        logger.LogWarning("⚠️ A restart is required for settings to take effect.");
        logger.LogInformation("\n🎉 Setup flow finished.");
    }

    private async Task BackupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("🧳 {BannerLine}", BannerLine);
        logger.LogInformation("💾 macOS Backup Wizard");
        logger.LogWarning("⚠️ This will backup your current macOS configuration.");
        logger.LogInformation("🧳 {BannerLine}", BannerLine);

        foreach (var service in services.Where(candidate => candidate.IncludeInWorkflow))
        {
            await service.BackupAsync(cancellationToken);
        }

        logger.LogInformation("\n🎉 Backup flow finished.");
        logger.LogInformation("📝 Next: Commit and push the updated Brewfile to Git.");
        logger.LogInformation("☁️ Next: Store the mackup backup folder safely (NAS, cloud, etc.).");
        logger.LogInformation("🔐 Next: Store the Raycast backup file safely.");
    }

    private async Task RunStepAsync(string stepName, Func<Task> action)
    {
        if (!promptService.SkipStep(stepName))
        {
            await action();
        }
    }
}
