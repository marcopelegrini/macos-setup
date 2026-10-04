using System.CommandLine;
using Microsoft.Extensions.Logging;

namespace MacSetup;

using MacSetup.SetupServices;

internal sealed class MacSetupApp(
    ILogger<MacSetupApp> logger,
    PromptService promptService,
    IEnumerable<ISetupBackupService> services)
{
    private const string BannerLine = "════════════════════════════════════════════";

    public Task<int> RunAsync(string[] args, CancellationToken cancellationToken)
        => BuildRootCommand().Parse(args).InvokeAsync(configuration: null, cancellationToken);

    private RootCommand BuildRootCommand()
    {
        var root = new RootCommand("macOS setup CLI");

        root.Subcommands.Add(MakeCommand(
            "setup",
            "Run the full setup workflow",
            SetupAsync));

        root.Subcommands.Add(MakeCommand(
            "backup",
            "Back up current macOS (Brewfile, mackup, etc)",
            BackupAsync));

        foreach (var service in services)
        {
            var serviceCommand = new Command(service.CommandName, service.GetStepName());
            serviceCommand.Subcommands.Add(MakeCommand(
                "setup",
                $"Run setup for {service.CommandName}",
                service.SetupAsync));
            serviceCommand.Subcommands.Add(MakeCommand(
                "backup",
                $"Run backup for {service.CommandName}",
                service.BackupAsync));
            root.Subcommands.Add(serviceCommand);
        }

        return root;
    }

    private Command MakeCommand(string name, string description, Func<CancellationToken, Task> action)
    {
        var command = new Command(name, description);
        command.SetAction(async (_, ct) =>
        {
            try
            {
                await action(ct);
                return 0;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Command failed");
                return 1;
            }
        });
        return command;
    }

    private async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("🚀 {BannerLine}", BannerLine);
        logger.LogInformation("🛠️  macOS Setup Wizard");
        logger.LogInformation("📦 Includes: sudo, dotfiles, Homebrew, App Store apps, Dock, Mackup, Raycast, macOS settings");
        logger.LogWarning("🔐 Sudo may be requested multiple times during this run");
        logger.LogInformation("🚀 {BannerLine}", BannerLine);

        if (!promptService.Confirm("Continue with setup?"))
        {
            logger.LogWarning("🛑 Setup cancelled");
            return;
        }

        foreach (var service in services.Where(candidate => candidate.IncludeInWorkflow))
        {
            await RunStepAsync(service.GetStepName(), () => service.SetupAsync(cancellationToken));
        }

        logger.LogWarning("⚠️ A restart is required for settings to take effect");
        logger.LogInformation("🎉 Setup flow finished");
    }

    private async Task BackupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("🧳 {BannerLine}", BannerLine);
        logger.LogInformation("💾 macOS Backup Wizard");
        logger.LogWarning("⚠️ This will backup your current macOS configuration");
        logger.LogInformation("🧳 {BannerLine}", BannerLine);

        foreach (var service in services.Where(candidate => candidate.IncludeInWorkflow))
        {
            await service.BackupAsync(cancellationToken);
        }

        logger.LogInformation("🎉 Backup flow finished");
        logger.LogInformation("📝 Next: Commit and push the updated Brewfile to Git");
        logger.LogInformation("☁️ Next: Store the mackup backup folder safely (NAS, cloud, etc.)");
        logger.LogInformation("🔐 Next: Store the Raycast backup file safely");
    }

    private async Task RunStepAsync(string stepName, Func<Task> action)
    {
        if (!promptService.SkipStep(stepName))
        {
            await action();
        }
    }
}
