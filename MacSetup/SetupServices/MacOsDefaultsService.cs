namespace MacSetup;

internal sealed class MacOsDefaultsService(AppPaths paths, CommandRunner commandRunner, PromptService prompts) : ISetupBackupService
{
    public string CommandName => "osx";

    public bool IncludeInWorkflow => true;

    public string GetStepName() => "Apply macOS Settings";

    private static readonly string[] Commands =
    [
        "defaults write NSGlobalDomain AppleInterfaceStyle -string Dark",
        "defaults write NSGlobalDomain AppleIconAppearanceTheme -string RegularDark",
        "defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true",
        "defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true",
        "defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false",
        "defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true",
        "systemsetup -setrestartfreeze on",
        "defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false",
        "defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false",
        "defaults write NSGlobalDomain AppleWindowTabbingMode -string always",
        "defaults write com.apple.spaces spans-displays -bool true",
        "defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false",
        "defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0",
        "defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0",
        "defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true",
        "defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true",
        "defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0",
        "defaults write NSGlobalDomain ContextMenuGesture -int 1",
        "defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false",
        "defaults write NSGlobalDomain InitialKeyRepeat -int 20",
        "defaults write NSGlobalDomain KeyRepeat -int 1",
        "defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true",
        "defaults write NSGlobalDomain AppleKeyboardUIMode -int 3",
        "defaults write NSGlobalDomain TrackpadThreeFingerHorizSwipeGesture -int 1",
        "defaults write com.apple.screencapture location -string '${HOME}/Downloads'",
        "defaults write com.apple.screencapture type -string 'jpg'",
        "defaults write com.apple.finder NewWindowTarget -string 'PfDe'",
        "defaults write com.apple.finder NewWindowTargetPath -string 'file://${HOME}/Downloads/'",
        "defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true",
        "defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true",
        "defaults write com.apple.finder ShowMountedServersOnDesktop -bool true",
        "defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true",
        "defaults write com.apple.finder AppleShowAllFiles -bool false",
        "defaults write NSGlobalDomain AppleShowAllExtensions -bool false",
        "defaults write com.apple.finder ShowStatusBar -bool true",
        "defaults write com.apple.finder QLEnableTextSelection -bool true",
        "defaults write com.apple.finder _FXShowPosixPathInTitle -bool false",
        "defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'",
        "defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false",
        "defaults write NSGlobalDomain com.apple.springing.enabled -bool true",
        "defaults write NSGlobalDomain com.apple.springing.delay -float 0.1",
        "defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true",
        "/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist",
        "/usr/libexec/PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist",
        "/usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist",
        "/usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist",
        "/usr/libexec/PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist",
        "/usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist",
        "defaults write com.apple.finder FXPreferredViewStyle -string 'clmv'",
        "defaults write com.apple.finder _FXSortFoldersFirst -bool true",
        "defaults write com.apple.finder _FXEnableColumnAutoSizing -bool true",
        "chflags nohidden ~/Library",
        "defaults write com.apple.dock tilesize -int 26",
        "defaults write com.apple.dock magnification -bool true",
        "defaults write com.apple.dock largesize -int 90",
        "defaults write com.apple.dock expose-animation-duration -float 0.15",
        "defaults write com.apple.dock showhidden -bool true",
        "defaults write com.apple.universalaccess reduceTransparency -bool true",
        "defaults write com.apple.dock wvous-br-corner -int 2",
        "defaults write com.apple.dock wvous-br-modifier -int 0",
        "defaults write com.apple.dock wvous-bl-corner -int 4",
        "defaults write com.apple.dock wvous-bl-modifier -int 0",
        "defaults write com.apple.Safari IncludeDevelopMenu -bool true",
        "defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true",
        "defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true",
        "defaults write NSGlobalDomain WebKitDeveloperExtras -bool true",
        "defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false",
        "defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{enabled = 0; value = { parameters = (32, 49, 1048576); type = '\''standard'\''; }; }'",
        "mdutil -a -i off",
        "killall mds > /dev/null 2>&1",
        "defaults write com.apple.ActivityMonitor OpenMainWindow -bool true",
        "defaults write com.apple.ActivityMonitor ShowCategory -int 0",
        "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false",
        "defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false",
        "defaults write com.apple.appstore InAppReviewEnabled -int 0",
    ];

    public async Task SetupAsync(CancellationToken cancellationToken)
    {
        if (Environment.UserName != "root")
        {
            Console.WriteLine();
            Console.WriteLine("Requesting sudo to apply macOS settings...");
            await commandRunner.RunAsync(
                "sudo",
                ["dotnet", "run", "--project", Path.Combine(paths.RootPath, "MacSetup", "MacSetup.csproj"), "--", "osx"],
                paths.RootPath,
                cancellationToken: cancellationToken);
            return;
        }

        Console.WriteLine();
        Console.WriteLine("━━━ ⚙️ Apply macOS Settings");

        foreach (var command in Commands)
        {
            await commandRunner.RunShellAsync(command, cancellationToken: cancellationToken);
        }

        if (prompts.Confirm("Restart affected applications now?"))
        {
            foreach (var app in new[] { "cfprefsd", "Dock", "Finder", "Mail", "SystemUIServer" })
            {
                await commandRunner.RunAsync("killall", [app], throwOnError: false, cancellationToken: cancellationToken);
            }
        }

        Console.WriteLine("Please log out and log back in to make all settings take effect.");
    }

    public Task BackupAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        Console.WriteLine();
        Console.WriteLine("━━━ ⚙️ Backup macOS Settings");
        Console.WriteLine("Skipping macOS defaults backup: no backup operation is defined.");
        return Task.CompletedTask;
    }
}
