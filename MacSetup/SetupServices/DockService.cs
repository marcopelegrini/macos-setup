namespace MacSetup.SetupServices;

internal sealed class DockService(CommandRunner commandRunner) : ISetupBackupService
{
    public string CommandName => "dock";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Configure Dock";

    private static readonly string[] DockItems =
    [
        "/Applications/Brave Browser.app",
        "/Applications/Microsoft Edge.app",
        "/Applications/Microsoft Outlook.app",
        "/Applications/Microsoft Teams.app",
        "/Applications/ChatGPT.app",
        "/Applications/Claude.app",
        "/Applications/Ollama.app",
        "/Applications/Microsoft 365 Copilot.app",
        "/Users/marco/Applications/Brave Browser Apps.localized/Whimsical.app",
        "/Applications/Obsidian.app",
        "/Applications/iTerm.app",
        "/Users/marco/Applications/Rider.app",
        "/Users/marco/Applications/IntelliJ IDEA.app",
        "/Users/marco/Applications/WebStorm.app",
        "/Applications/Visual Studio Code.app",
        "/Applications/Windows App.app",
        "/Applications/Azure VPN Client.app",
        "/System/Applications/Messages.app",
        "/Applications/WhatsApp.app",
        "/System/Applications/FaceTime.app",
        "/System/Applications/Reminders.app",
        "/System/Applications/Notes.app",
        "/Applications/Affinity.app",
        "/Applications/UTM.app",
        "/Applications/UGREEN NAS.app",
        "/System/Applications/System Settings.app",
        "/System/Applications/App Store.app",
    ];

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        Console.WriteLine();
        Console.WriteLine("━━━ 🧭 Configure Dock");
        Console.WriteLine("Removing all dock items...");
        await commandRunner.RunAsync("dockutil", ["--remove", "all", "--no-restart"], cancellationToken: cancellationToken);
        await commandRunner.RunAsync("dockutil", ["--add", "", "--type", "spacer", "--section", "apps", "--no-restart"], cancellationToken: cancellationToken);

        var addedItemNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var item in DockItems)
        {
            if (!Directory.Exists(item) && !File.Exists(item))
            {
                Console.WriteLine($"Skipping missing Dock item: {item}");
                continue;
            }

            await commandRunner.RunAsync("dockutil", ["--add", item, "--no-restart"], cancellationToken: cancellationToken);
            addedItemNames.Add(Path.GetFileNameWithoutExtension(item));
        }

        await AddSpacerAfterIfPresentAsync("Microsoft Teams", addedItemNames, cancellationToken);
        await AddSpacerAfterIfPresentAsync("Obsidian", addedItemNames, cancellationToken);
        await AddSpacerAfterIfPresentAsync("Azure VPN Client", addedItemNames, cancellationToken);
        await AddSpacerAfterIfPresentAsync("Notes", addedItemNames, cancellationToken);
        await AddSpacerAfterIfPresentAsync("System Settings", addedItemNames, cancellationToken);
        await commandRunner.RunAsync("killall", ["Dock"], throwOnError: false, cancellationToken: cancellationToken);
    }

    private async Task AddSpacerAfterIfPresentAsync(
        string appName,
        HashSet<string> addedItemNames,
        CancellationToken cancellationToken)
    {
        if (!addedItemNames.Contains(appName))
        {
            Console.WriteLine($"Skipping spacer after '{appName}' because the app is not in Dock items.");
            return;
        }

        await commandRunner.RunAsync(
            "dockutil",
            ["--add", "", "--type", "spacer", "--section", "apps", "--after", appName, "--no-restart"],
            cancellationToken: cancellationToken);
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Console.WriteLine();
        Console.WriteLine("━━━ 🧭 Backup Dock");
        Console.WriteLine("Skipping Dock backup: no backup operation is defined.");
        return Task.CompletedTask;
    }
}
