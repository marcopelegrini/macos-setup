# Backup / Restore macos

## Setup new macos

### Steps

#### Basic

- Get this folder to the macos via Git, NAS, etc.
- Get the dotfiles folder into the macos (default path in the `dotfiles.sh` is $HOME/OSX/dotfiles)
- Run `dotfiles.sh`
- Authenticate in the App Store
- Run `osx.sh`
- Restart macos, yes, `restart`

#### Apps and CLIs

- Install brew `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Run `brew bundle`
- Get a coffee, cake and watch the news
- Run `mas.sh`
- Run `dock.sh`

#### Restore backups

- Get the mackup folder into the macos
- Files are restored from the folder defined in the `~/.mackup.cfg`
- Run `mackup restore`

- Restore Rayscast backup

### In case something is not right and adjusts need to be made

#### macos settings

- Run `compare-defaults.sh`

Make the change needed in another terminal

- Finish the script
- Identify the difference and save it to the `osx.sh`

#### Missing Apps / CLIs

- Add them to Brewfile

## Backup existing macos

- Run `brew bundle dump`
- Compare results with Bundlefile in this folder, make necessary adjustments

- Run `mackup backup`
- Files are backup to the folder defined in the `~/.mackup.cfg`
- Store mackup folder somewhere

- Backup Raycast
