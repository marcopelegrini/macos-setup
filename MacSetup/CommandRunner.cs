using System.Diagnostics;
using Microsoft.Extensions.Logging;

namespace MacSetup;

internal sealed class CommandRunner(ILogger<CommandRunner> logger)
{
    public async Task<int> RunAsync(
        string fileName,
        IEnumerable<string> arguments,
        string? workingDirectory = null,
        bool throwOnError = true,
        IDictionary<string, string?>? environmentVariables = null,
        CancellationToken cancellationToken = default)
    {
        var argumentList = arguments.ToList();
        logger.LogDebug("Executing command: {FileName} {Arguments}", fileName, string.Join(' ', argumentList));

        var startInfo = new ProcessStartInfo
        {
            FileName = fileName,
            UseShellExecute = false,
            RedirectStandardOutput = false,
            RedirectStandardError = false,
            WorkingDirectory = workingDirectory ?? Directory.GetCurrentDirectory(),
        };

        foreach (var argument in argumentList)
        {
            startInfo.ArgumentList.Add(argument);
        }

        if (environmentVariables is not null)
        {
            foreach (var entry in environmentVariables)
            {
                startInfo.Environment[entry.Key] = entry.Value;
            }
        }

        using var process = Process.Start(startInfo);
        if (process is null)
        {
            throw new InvalidOperationException($"Failed to start process: {fileName}");
        }

        await process.WaitForExitAsync(cancellationToken);
        if (throwOnError && process.ExitCode != 0)
        {
            throw new InvalidOperationException($"Command failed with exit code {process.ExitCode}: {fileName} {string.Join(' ', argumentList)}");
        }

        return process.ExitCode;
    }

    public Task<int> RunShellAsync(
        string command,
        string? workingDirectory = null,
        bool throwOnError = true,
        IDictionary<string, string?>? environmentVariables = null,
        CancellationToken cancellationToken = default) =>
        RunAsync("/bin/bash", ["-lc", command], workingDirectory, throwOnError, environmentVariables, cancellationToken);

    public async Task<string?> CaptureAsync(string fileName, IEnumerable<string> arguments, CancellationToken cancellationToken = default)
    {
        var argumentList = arguments.ToList();
        var startInfo = new ProcessStartInfo
        {
            FileName = fileName,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
        };

        foreach (var argument in argumentList)
        {
            startInfo.ArgumentList.Add(argument);
        }

        using var process = Process.Start(startInfo);
        if (process is null)
        {
            return null;
        }

        var output = await process.StandardOutput.ReadToEndAsync(cancellationToken);
        await process.WaitForExitAsync(cancellationToken);
        return process.ExitCode == 0 ? output.Trim() : null;
    }
}
