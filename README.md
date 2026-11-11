# macstrap

Backup and Restore utility for macOS.
[Task](https://taskfile.dev) orchestrates the steps in `macstrap/Taskfile.yml`; each step is a bash script in
`macstrap/scripts`.

## Dependencies:

- [brew](https://brew.sh/) for most apps and CLI installations
- [Task](https://taskfile.dev) to run the setup and backup tasks
- [mas](https://github.com/mas-cli/mas) for 'App Store' installations
- [dockutil](https://github.com/kcrawford/dockutil) for dock manipulation
- [mackup](https://github.com/lra/mackup) to backup several app preferences

## Tasks

| Task                  | Purpose                                                       |
|-----------------------|---------------------------------------------------------------|
| `sudo:setup`          | Enable Touch ID for sudo                                      |
| `homebrew:setup`      | Install Homebrew and apps from the Brewfile                   |
| `homebrew:backup`     | Dump installed packages and review them against the Brewfile  |
| `dotfiles:setup`      | Symlink dotfiles into the user profile folder                 |
| `launch-agents:setup` | Symlink and load/reload launch agent plists                   |
| `dock:setup`          | Replace Dock items and add configured spacers                 |
| `mas:setup`           | Install configured App Store apps                             |
| `mackup:setup`        | Restore application preferences                               |
| `mackup:backup`       | Back up application preferences                               |
| `raycast:setup`       | Guide manual settings import                                  |
| `raycast:backup`      | Guide manual settings export                                  |
| `osx:setup`           | Apply configured macOS settings                               |
| `compare-defaults`    | Compare preferences before and after a manual change          |

`setup` runs every `*:setup` task in the order above, and `backup` runs every `*:backup` task.
During `setup`, press any key within 5 seconds of a step's prompt to skip it.

## Setup configuration

| Setting                                          | Location                                     |
|--------------------------------------------------|----------------------------------------------|
| Brewfile, Mackup, dotfiles, launch agent paths   | `vars` in `macstrap/Taskfile.yml`            |
| Sudo PAM file, rule, and mode                    | `vars` in `macstrap/Taskfile.yml`            |
| Dock items and spacers                           | `macstrap/config/dock.txt`                   |
| App Store app IDs                                | `macstrap/config/mas.txt`                    |
| macOS settings and applications to restart       | `macstrap/config/osx.sh`                     |

Override a `vars` value for one run by passing it on the command line, for example
`task -t macstrap/Taskfile.yml dotfiles:setup DOTFILES_DIR=$HOME/dotfiles`.

Each line in `dock.txt` is an app name without `.app`, searched in `/Applications` and then `/System/Applications`, or
an absolute path for apps stored elsewhere; `~` expands to the user profile folder.
A `---` line adds a spacer after the previous item.
Homebrew backup writes its temporary comparison file alongside the Brewfile with a `.new` suffix.

## Run

Run tasks from the `macstrap` folder, or pass `-t macstrap/Taskfile.yml` from elsewhere.

- `task --list`
- `task setup`
- `task backup`
- `task <task>`, for example `task dock:setup`

## Setup new macOS

- Get this folder to the Mac via Git, NAS, etc.
- Run `macstrap/bootstrap.sh`.
  It installs Homebrew and Task when missing, then runs `task setup`.
  Pass a task name to run a single task instead, for example `macstrap/bootstrap.sh dotfiles:setup`.

## Backup existing macOS

- Run `task backup`

## macOS settings

- Run `task compare-defaults`
- Make the change needed in System Settings or the app
- Return to the terminal and press Enter
- Add the reported difference as a command in `macstrap/config/osx.sh`
