namespace MacSetup.SetupServices;

internal interface ISetupBackupService
{
    string CommandName { get; }

    bool IncludeInWorkflow { get; }

    string GetStepName();

    Task SetupAsync(CancellationToken cancellationToken);

    Task BackupAsync(CancellationToken cancellationToken);
}
