#!/bin/bash

# ==============================================================================
# macOS System Preferences
# ==============================================================================
# Run this script to configure macOS settings.
# Some changes require a logout/restart to take effect.

set -e

echo "==> Configuring macOS settings..."

# Close any open System Preferences panes to prevent them from overriding settings
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ------------------------------------------------------------------------------
# Keyboard
# ------------------------------------------------------------------------------
echo "==> Keyboard settings..."

# Set a fast keyboard repeat rate (lower = faster)
# Default is 6 (about 30ms)
defaults write NSGlobalDomain KeyRepeat -int 1

# Set a short delay until key repeat (lower = shorter delay)
# Default is 25 (about 375ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ------------------------------------------------------------------------------
# Mouse / Trackpad
# ------------------------------------------------------------------------------
echo "==> Mouse settings..."

# Disable mouse acceleration
defaults write .GlobalPreferences com.apple.mouse.scaling -1

# Disable trackpad acceleration (if using trackpad)
defaults write .GlobalPreferences com.apple.trackpad.scaling -1

# Disable "natural" (inverted) scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ------------------------------------------------------------------------------
# Finder
# ------------------------------------------------------------------------------
echo "==> Finder settings..."

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# ------------------------------------------------------------------------------
# Dock
# ------------------------------------------------------------------------------
echo "==> Dock settings..."

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 48

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# ------------------------------------------------------------------------------
# Screenshots
# ------------------------------------------------------------------------------
echo "==> Screenshot settings..."

# Save screenshots to the Desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ------------------------------------------------------------------------------
# Apply Changes
# ------------------------------------------------------------------------------
echo "==> Restarting affected applications..."

for app in "Finder" "Dock" "SystemUIServer"; do
    killall "${app}" &> /dev/null || true
done

echo ""
echo "==> macOS settings configured!"
echo ""
echo "    Note: Some changes require a logout/restart to take effect."
echo "    - Keyboard repeat settings require logout"
echo "    - Mouse acceleration requires logout"
echo ""
