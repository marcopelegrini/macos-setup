#!/bin/sh

# List all current dock items and remove them
echo "Removing all dock items..."
dockutil --remove all --no-restart

# Array of applications to add
dock_items_to_add=(
  "/Applications/Brave Browser.app"
  "/Applications/Microsoft Edge.app"
  "/Applications/Microsoft Outlook.app"
  "/Applications/Microsoft Teams.app"
  "/Applications/ChatGPT.app"
  "/Applications/Claude.app"
  "/Applications/Ollama.app"
  "/Applications/Microsoft 365 Copilot.app"
  "/Applications/iTerm.app"
  "/Users/marco/Applications/Rider.app"
  "/Users/marco/Applications/IntelliJ IDEA.app"
  "/Users/marco/Applications/WebStorm.app"
  "/Applications/Visual Studio Code.app"
  "/Applications/Windows App.app"
  "/Applications/Azure VPN Client.app"
  "/System/Applications/Messages.app"
  "/Applications/WhatsApp.app"
  "/System/Applications/FaceTime.app"
  "/System/Applications/Reminders.app"
  "/Applications/Affinity.app"
  "/Applications/UGREEN NAS.app"
  "/System/Applications/System Settings.app"
  "/System/Applications/App Store.app"
)

dockutil --add '' --type spacer --section apps --no-restart

# Add each item to the Dock
for app in "${dock_items_to_add[@]}"; do
  dockutil --add "$app" --no-restart
done

# Add spacers after specific apps
dockutil --add '' --type spacer --section apps --after "Microsoft Teams" --no-restart
dockutil --add '' --type spacer --section apps --after "Microsoft 365 Copilot" --no-restart
dockutil --add '' --type spacer --section apps --after "Azure VPN Client" --no-restart
dockutil --add '' --type spacer --section apps --after "Reminders" --no-restart
dockutil --add '' --type spacer --section apps --after "System Settings" --no-restart

# Restart Dock once after all changes
killall Dock