# Backup / Restore macos

Uses:

- [brew](https://brew.sh/) for most apps and CLI installations
- [mas](https://github.com/mas-cli/mas) for 'App Store' installations
- [dockutil](https://github.com/kcrawford/dockutil) for dock manipulation
- [mackup](https://github.com/lra/mackup) to backup several app preferences
- dotfiles command to symlink dotfiles
- compare-defaults command to find differences in macOS preferences

## Install dotnet

`curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin`

## Build

- `dotnet build MacSetup/MacSetup.csproj`

## Run

- `dotnet run --project MacSetup/MacSetup.csproj -- --help`
- `dotnet run --project MacSetup/MacSetup.csproj -- setup --mode personal`
- `dotnet run --project MacSetup/MacSetup.csproj -- backup --mode corporate`

## Setup new macos

- Get this folder to the macos via Git, NAS, etc.
- Run `dotnet run --project MacSetup/MacSetup.csproj -- setup`

## Backup existing macos

- Run `dotnet run --project MacSetup/MacSetup.csproj -- backup`

## Macos settings

- Run `dotnet run --project MacSetup/MacSetup.csproj -- compare-defaults`

Make the change needed in another terminal

- Finish the script
- Identify the difference and save it to the macOS defaults command set in the .NET app
