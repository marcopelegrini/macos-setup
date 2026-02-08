# Backup / Restore macos

Uses:

- [brew](https://brew.sh/) for most apps and CLI installations
- [mas](https://github.com/mas-cli/mas) for 'App Store' installations
- [dockutil](https://github.com/kcrawford/dockutil) for dock manipulation
- [mackup](https://github.com/lra/mackup) to backup several app preferences
- [dotfiles.sh](https://github.com/marcopelegrini/macos-setup/blob/main/dotfiles.sh) to symlink dotfiles
- [compare-defaults.sh](https://github.com/marcopelegrini/macos-setup/blob/main/compare-defaults.sh) to find out differences in macos preferences

## Setup new macos

- Get this folder to the macos via Git, NAS, etc.
- Run `setup.sh setup`

## Backup existing macos

- Run `setup.sh backup`

## Macos settings

- Run `compare-defaults.sh`

Make the change needed in another terminal

- Finish the script
- Identify the difference and save it to the `osx.sh`