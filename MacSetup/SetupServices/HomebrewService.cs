namespace MacSetup.SetupServices;

using Microsoft.Extensions.Logging;

internal sealed class HomebrewService(
    AppPaths paths,
    CommandRunner commandRunner,
    PromptService prompts,
    ILogger<HomebrewService> logger) : ISetupBackupService
{
    public string CommandName => "homebrew";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Install Homebrew, Apps and CLIs";

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("━━━ 🍺 Install Homebrew, Apps and CLIs");
        var brewCommand = await GetBrewCommandAsync(cancellationToken);
        if (brewCommand is not null)
        {
            logger.LogInformation("Homebrew already installed");
        }
        else
        {
            if (prompts.SkipStep("Install Homebrew"))
            {
                return;
            }

            logger.LogInformation("Installing Homebrew...");
            await commandRunner.RunShellAsync("$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)", throwOnError: true, cancellationToken: cancellationToken);

            brewCommand = await GetBrewCommandAsync(cancellationToken);
            if (brewCommand is null)
            {
                throw new InvalidOperationException("Homebrew installation failed.");
            }

            logger.LogInformation("Homebrew installed");
        }

        if (prompts.SkipStep("Install Apps and CLIs"))
        {
            return;
        }

        if (File.Exists(paths.BrewfilePath))
        {
            logger.LogInformation("Running brew bundle...");
            logger.LogWarning("This may take a while. Time for coffee!");
            await commandRunner.RunAsync(brewCommand, ["bundle"], paths.RootPath, cancellationToken: cancellationToken);
            logger.LogInformation("Homebrew bundle installed");
        }
    }

    public async Task BackupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("━━━ 🍺 Backup Homebrew");
        var brewCommand = await GetBrewCommandAsync(cancellationToken);
        if (brewCommand is null)
        {
            throw new InvalidOperationException("Homebrew is not installed.");
        }

        logger.LogInformation("Dump Homebrew bundle");
        logger.LogInformation("Running brew bundle dump...");
        await commandRunner.RunAsync(brewCommand, ["bundle", "dump", "--file", "Brewfile.new"], paths.RootPath, cancellationToken: cancellationToken);
        logger.LogInformation("Brewfile.new created");

        logger.LogInformation("Compare Brewfiles");
        logger.LogInformation("Sorting both Brewfiles in place...");
        await commandRunner.RunAsync("sort", [paths.BrewfilePath, "-o", paths.BrewfilePath], cancellationToken: cancellationToken);
        await commandRunner.RunAsync("sort", [Path.Combine(paths.RootPath, "Brewfile.new"), "-o", Path.Combine(paths.RootPath, "Brewfile.new")], cancellationToken: cancellationToken);

        logger.LogWarning("VS Code will now open to compare both files");
        logger.LogInformation("1. Review differences between old and new Brewfile");
        logger.LogInformation("2. Update Brewfile with new packages or remove unneeded ones");
        logger.LogInformation("3. Save the Brewfile (Brewfile.new) will be deleted");
        logger.LogInformation("4. Close VS Code and return here to continue");
        prompts.Pause("Press Enter to open VS Code...");

        await commandRunner.RunAsync("code", ["--diff", paths.BrewfilePath, Path.Combine(paths.RootPath, "Brewfile.new"), "--wait"], cancellationToken: cancellationToken);
        File.Delete(Path.Combine(paths.RootPath, "Brewfile.new"));
        logger.LogInformation("Brewfile comparison complete");
    }

    private async Task<string?> GetBrewCommandAsync(CancellationToken cancellationToken)
    {
        var whichResult = await commandRunner.CaptureAsync("/usr/bin/which", ["brew"], cancellationToken);
        if (!string.IsNullOrWhiteSpace(whichResult))
        {
            return whichResult;
        }

        foreach (var candidate in new[] { "/opt/homebrew/bin/brew", "/usr/local/bin/brew" })
        {
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        return null;
    }
}
