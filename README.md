# Backup / Restore macos

## Setup new macos

### Steps

- Get this folder to the macos via Git, NAS, etc.
- Get the dotfiles folder into the macos (default path in the `dotfiles.sh` is $HOME/OSX/dotfiles)
- Run `dotfiles.sh`
- Authenticate in the App Store
- Run `osx.sh`
- Restart macos, yes, `restart`
- Install brew `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Run `brew bundle`
- Get a coffee, cake and watch the news
- Run `mas.sh`
- Run `dock.sh`
- Run `mackup restore`

### In case something is not right and adjusts need to be made

#### macos settings

- Run `compare-defaults.sh`

Make the change needed in another terminal

- Finish the script
- Identify the difference and save it to the `osx.sh`

#### Missing apps / commands

Add them to Brewfile

## Backup existing macos

- Run `brew bundle dump`
- Compare results with Bundlefile in this folder, make necessary adjustments

- Run `mackup backup`