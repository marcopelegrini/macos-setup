namespace MacSetup;

internal sealed class PlatformService
{
    public void EnsureMacOs()
    {
        if (!OperatingSystem.IsMacOS())
        {
            throw new InvalidOperationException("This application is designed for macOS only.");
        }
    }

    public void EnsureRootForOsxCommand()
    {
        if (Environment.UserName != "root")
        {
            throw new InvalidOperationException("This command must be run as root. Please use: sudo dotnet run --project MacSetup/MacSetup.csproj -- osx");
        }
    }
}
