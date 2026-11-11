# macOS settings applied by `task osx:setup`. Sourced by scripts/osx.sh; runs as the logged-in user.
# Use `task compare-defaults` to discover the command for a setting changed in System Settings.

RESTART_APPLICATIONS=(
  cfprefsd
  Dock
  Finder
  Mail
  SystemUIServer
)

apply_settings() {
  defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
  defaults write NSGlobalDomain AppleIconAppearanceTheme -string RegularDark
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true
  sudo systemsetup -setrestartfreeze on
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain AppleWindowTabbingMode -string always
  defaults write com.apple.spaces spans-displays -bool true
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
  defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
  defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
  defaults write NSGlobalDomain ContextMenuGesture -int 1
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain InitialKeyRepeat -int 20
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  defaults write NSGlobalDomain TrackpadThreeFingerHorizSwipeGesture -int 1
  defaults write com.apple.screencapture location -string "${HOME}/Downloads"
  defaults write com.apple.screencapture type -string 'jpg'
  defaults write com.apple.finder NewWindowTarget -string 'PfDe'
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
  defaults write com.apple.finder AppleShowAllFiles -bool false
  defaults write NSGlobalDomain AppleShowAllExtensions -bool false
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder QLEnableTextSelection -bool true
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool false
  defaults write com.apple.finder FXDefaultSearchScope -string 'SCcf'
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true
  defaults write NSGlobalDomain com.apple.springing.delay -float 0.1
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy grid' ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c 'Set :FK_StandardViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c 'Set :StandardViewSettings:IconViewSettings:iconSize 64' ~/Library/Preferences/com.apple.finder.plist
  defaults write com.apple.finder FXPreferredViewStyle -string 'clmv'
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  defaults write com.apple.finder _FXEnableColumnAutoSizing -bool true
  chflags nohidden ~/Library
  defaults write com.apple.dock tilesize -int 26
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int 90
  defaults write com.apple.dock expose-animation-duration -float 0.15
  defaults write com.apple.dock showhidden -bool true
  defaults write com.apple.universalaccess reduceTransparency -bool true
  defaults write com.apple.dock wvous-br-corner -int 2
  defaults write com.apple.dock wvous-br-modifier -int 0
  defaults write com.apple.dock wvous-bl-corner -int 4
  defaults write com.apple.dock wvous-bl-modifier -int 0
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '{enabled = 0; value = { parameters = (32, 49, 1048576); type = '\''standard'\''; }; }'
  sudo mdutil -a -i off
  sudo killall mds > /dev/null 2>&1
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
  defaults write com.apple.ActivityMonitor ShowCategory -int 0
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'automaticQuoteSubstitutionEnabled' -bool false
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add 'continuousSpellCheckingEnabled' -bool false
  defaults write com.apple.appstore InAppReviewEnabled -int 0
}
