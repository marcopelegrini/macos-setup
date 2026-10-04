namespace MacSetup.SetupServices;

using Microsoft.Extensions.Logging;

internal sealed class SudoersService(CommandRunner commandRunner, ILogger<SudoersService> logger) : ISetupBackupService
{
    public string CommandName => "sudoers";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Configure Passwordless Sudo";

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        logger.LogInformation("━━━ 🔧 Configure Passwordless Sudo");
        var sudoersFile = "/etc/sudoers.d/admin_nopasswd";
        await commandRunner.RunShellAsync($"echo '%admin ALL=(ALL) NOPASSWD: ALL' | sudo tee {sudoersFile} > /dev/null", cancellationToken: cancellationToken);
        await commandRunner.RunAsync("sudo", ["chmod", "0440", sudoersFile], cancellationToken: cancellationToken);
        var exitCode = await commandRunner.RunAsync("sudo", ["visudo", "-c", "-f", sudoersFile], throwOnError: false, cancellationToken: cancellationToken);
        if (exitCode == 0)
        {
            logger.LogInformation("✅ Passwordless sudo configured successfully");
        }
        else
        {
            logger.LogWarning("⚠️ Sudoers syntax validation failed; removing configuration for safety");
            await commandRunner.RunAsync("sudo", ["rm", "-f", sudoersFile], cancellationToken: cancellationToken);
        }
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        logger.LogInformation("━━━ 🔧 Backup Passwordless Sudo");
        logger.LogInformation("Skipping sudoers backup: no backup operation is defined");
        return Task.CompletedTask;
    }
}
