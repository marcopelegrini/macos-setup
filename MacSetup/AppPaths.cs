namespace MacSetup;

internal sealed class AppPaths
{
    public AppPaths()
    {
        RootPath = ResolveRootPath();
    }

    public string RootPath { get; }

    public string BrewfilePath => Path.Combine(RootPath, "Brewfile");

    public string MackupDirectory => Path.Combine(RootPath, "mackup");

    public string DotfilesDirectory => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "OSX", "dotfiles");

    private static string ResolveRootPath()
    {
        var envPath = Environment.GetEnvironmentVariable("MAC_SETUP_ROOT");
        if (!string.IsNullOrWhiteSpace(envPath))
        {
            return Path.GetFullPath(envPath);
        }

        var candidates = new[]
        {
            Directory.GetCurrentDirectory(),
            AppContext.BaseDirectory,
            Path.Combine(AppContext.BaseDirectory, "..", "..", "..", ".."),
        };

        foreach (var candidate in candidates)
        {
            var resolved = FindRepositoryRoot(candidate);
            if (resolved is not null)
            {
                return resolved;
            }
        }

        return Directory.GetCurrentDirectory();
    }

    private static string? FindRepositoryRoot(string startPath)
    {
        var current = new DirectoryInfo(Path.GetFullPath(startPath));
        while (current is not null)
        {
            var brewfilePath = Path.Combine(current.FullName, "Brewfile");
            var projectPath = Path.Combine(current.FullName, "src", "MacSetup", "MacSetup.csproj");
            if (File.Exists(brewfilePath) && File.Exists(projectPath))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        return null;
    }
}
