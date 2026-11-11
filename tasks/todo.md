# Configuration migration

## Launch agent symlink repair

- [x] Reproduce the label extraction failure without loading agents.
- [x] Handle dangling destination links and unlink confirmed replacements before copying.
- [x] Verify broken and valid links with isolated fixtures and fake launchctl.

Build succeeded without warnings or errors.
Isolated checks covered declined replacement, dangling-link replacement, valid-link target preservation,
and regular-file replacement without running real agents.

## Acceptance criteria

- Bind setup settings from `appsettings.json` through a shared `MacSetupOptions` object.
- Move Dock items and spacers, Homebrew fallback paths, App Store IDs, macOS defaults
  commands/restart applications, and sudoers settings into configuration without changing
  their current values.
- Load the configuration alongside the built application and preserve environment/command-line
  configuration precedence.
- Resolve Dock app names without `.app` under `/Applications` and `/System/Applications`;
  preserve explicit absolute paths.
- Leave pre-existing changes in `MacSetup/Program.cs` and `MacSetup/CliOptions.cs` intact.

## Checklist

- [x] Inspect setup services and existing repository changes.
- [x] Add shared options types and appsettings sections.
- [x] Bind options and update services to consume them.
- [x] Verify build and configuration loading.
- [x] Record results.

## Working notes

- `Host.CreateApplicationBuilder(args)` uses the current working directory for default JSON
  configuration, which did not load `MacSetup/appsettings.json` in the README invocation.
- Run configuration loading from the application output directory so it works for `dotnet run`
  and published execution while preserving normal host configuration precedence.
- Dock item names search `/Applications` before `/System/Applications`; absolute paths bypass
  name lookup.

## Results

- Added `MacSetupOptions` binding for Dock, Homebrew, App Store, macOS defaults, and sudoers
  settings in `MacSetup/appsettings.json`.
- Dock app names now resolve under `/Applications` and `/System/Applications`; absolute paths
  are used directly.
- `dotnet build MacSetup/MacSetup.csproj --no-restore` succeeded, and the CLI help command
  loaded the configuration successfully.

# Launch agents

## Acceptance criteria

- Install `.plist` files from `launch-agents` into the user's `Library/LaunchAgents` folder.
- Validate every plist and its label before installing or unloading any agents.
- Reload installed agents in the current user's GUI launchctl domain.
- Register the service in the setup workflow and expose `launch-agents setup`.
- Do not execute the repository's agents during development.

## Checklist

- [x] Inspect service patterns, plist files, and launchctl semantics.
- [x] Implement the service, configuration, path resolution, and registration.
- [x] Verify build, CLI registration, and isolated installation/reload behavior.
- [x] Document usage and record results.

## Working notes

- The user approved continuing on `main` with existing unstaged changes.
- Installation should load/reload agents immediately, rather than waiting for the next login.
- Root discovery still checks an obsolete `src/MacSetup` layout; fix the marker to locate
  `launch-agents` independently of the working directory.

## Results

- Added `LaunchAgentsService` and shared options for source and destination directories.
- Installation validates all sources, prompts before replacement, unloads existing labels,
  copies the plists, and bootstraps the new definitions.
- `dotnet build MacSetup/MacSetup.csproj --no-restore` succeeded without warnings or errors.
- CLI help and the backup no-op succeeded.
- Isolated fixtures with fake launchctl covered first installation, reload, declined replacement,
  invalid plist rejection, duplicate labels, and bootstrap error propagation.
- Root discovery was exercised from the parent directory.
- No repository agents were installed, unloaded, or started during validation.

# Configurable application paths

## Acceptance criteria

- Bind Brewfile, Mackup, and dotfiles paths from `MacSetup:Paths`.
- Resolve relative paths against the repository root and `$HOME` against the user profile.
- Preserve existing default locations and use the configured Brewfile throughout setup and backup.
- Preserve other existing edits and correct the root marker with user approval.

## Checklist

- [x] Inspect current path resolution and callers.
- [x] Add path configuration, resolution, and Homebrew integration.
- [x] Verify build, path expansion, and configured Brewfile usage.
- [x] Document results.

## Results

- Added `MacSetup:Paths` with defaults matching the existing Brewfile, Mackup, and dotfiles locations.
- `AppPaths` resolves relative paths against the repository root and a leading `$HOME` token
  against `Environment.SpecialFolder.UserProfile`.
- Homebrew setup uses the configured Brewfile explicitly; backup places the `.new` file alongside it.
- Build and CLI help succeeded.
- An isolated harness covered relative paths, absolute paths, `$HOME`, `$HOME/` prefixes, and empty-path rejection.
- Fake Homebrew and editor commands confirmed configured paths are used throughout setup and backup;
  the temporary comparison file was removed afterward.

# Service-owned path resolution

## Acceptance criteria

- Make `AppPaths` a static utility with root discovery and configured-path resolution.
- Resolve Brewfile, Mackup, and dotfiles paths in their respective services.
- Remove AppPaths dependency injection and migrate all callers without changing configuration keys or resolution rules.

## Checklist

- [x] Inspect all AppPaths bindings and classify the internal structural refactor.
- [x] Move path ownership into services and remove AppPaths registration.
- [x] Verify build, dependency injection, and configured path behavior.
- [x] Record results.

## Results

- `AppPaths` now exposes static `RootPath` and `ResolveConfiguredPath`.
- Homebrew, Mackup, and dotfiles services resolve their respective configured paths.
- All AppPaths constructor dependencies and its service registration were removed.
- `dotnet build MacSetup/MacSetup.csproj --no-restore` succeeded without warnings or errors.
- CLI help resolved all service constructors; dotfiles commands with nonexistent locations
  confirmed `$HOME` and relative path resolution without changing user files.
- The launch-agents backup no-op succeeded and `git diff --check` passed.
