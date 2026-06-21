namespace MacSetup;

internal sealed record CliOptions(
    string Command,
    string? Action = null)
{
    public static string HelpText => """
macOS setup CLI

Run from the repository root:
    dotnet run --project MacSetup/MacSetup.csproj -- <command> [options]

Commands:
    setup                         Run the full setup workflow
    backup                        Back up current configuration (Brewfile, mackup)
    homebrew <setup|backup>       Manage Homebrew packages
      setup                         Install packages from Brewfile
      backup                        Export installed packages to Brewfile
    dotfiles                      Symlink dotfiles from ~/OSX/dotfiles to ~
    dock                          Configure the macOS Dock via dockutil
    mas                           Install App Store apps via mas-cli
    osx                           Apply macOS system defaults (requires sudo)
    compare-defaults              Diff macOS defaults before and after a change

Examples:
    dotnet run --project MacSetup/MacSetup.csproj -- setup
    dotnet run --project MacSetup/MacSetup.csproj -- backup
    dotnet run --project MacSetup/MacSetup.csproj -- homebrew setup
    dotnet run --project MacSetup/MacSetup.csproj -- dotfiles
    dotnet run --project MacSetup/MacSetup.csproj -- osx
""";
}

internal static class CliParser
{
    public static CliOptions Parse(string[] args)
    {
        if (args.Length == 0 || IsHelp(args[0]))
        {
            return new CliOptions("help");
        }

        return args[0] switch
        {
            "homebrew" => ParseHomebrew(args[1..]),
            _ => ParseSimple(args[0], args[1..])
        };
    }

    private static CliOptions ParseSimple(string command, string[] args)
    {
        if (args.Length > 0)
        {
            throw new ArgumentException($"Unexpected arguments for {command}: {string.Join(' ', args)}");
        }

        return new CliOptions(command);
    }

    private static CliOptions ParseHomebrew(string[] args)
    {
        if (args.Length == 0 || IsHelp(args[0]))
        {
            throw new ArgumentException("homebrew requires an action: setup or backup");
        }

        var action = args[0];
        if (action is not ("setup" or "backup"))
        {
            throw new ArgumentException($"Unknown homebrew action: {action}");
        }

        if (args.Length > 1)
        {
            throw new ArgumentException($"Unexpected arguments for homebrew: {string.Join(' ', args[1..])}");
        }

        return new CliOptions("homebrew", Action: action);
    }

    private static bool IsHelp(string value) => value is "-h" or "--help" or "help";
}
