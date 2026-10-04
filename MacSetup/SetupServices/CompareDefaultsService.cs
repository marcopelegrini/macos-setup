namespace MacSetup.SetupServices;

internal sealed class CompareDefaultsService(CommandRunner commandRunner) : ISetupBackupService
{
    public string CommandName => "compare-defaults";

    public bool IncludeInWorkflow => false;

    public string GetStepName() => "Compare macOS Defaults";

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        var before = Path.GetTempFileName();
        var after = Path.GetTempFileName();

        try
        {
            Console.WriteLine("Capturing initial defaults...");
            await commandRunner.RunShellAsync($"defaults read > '{before}'", cancellationToken: cancellationToken);
            Console.Write("Initial capture complete. Make your changes, then press Enter to continue...");
            Console.ReadLine();
            Console.WriteLine("Capturing current defaults...");
            await commandRunner.RunShellAsync($"defaults read > '{after}'", cancellationToken: cancellationToken);
            Console.WriteLine();
            Console.WriteLine("=== DIFFERENCES ===");
            await commandRunner.RunShellAsync($"diff --unified=0 '{before}' '{after}' | grep -v '^@\\|^---\\|^+++'", throwOnError: false, cancellationToken: cancellationToken);
        }
        finally
        {
            File.Delete(before);
            File.Delete(after);
        }
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Console.WriteLine("Skipping defaults comparison backup: no backup operation is defined.");
        return Task.CompletedTask;
    }
}
