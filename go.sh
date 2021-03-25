#!/bin/sh

###############################################################################
# Settings                                                                    #
###############################################################################
source $HOME/goshsettings.txt

###############################################################################
# Notes                                                                       #
###############################################################################
#how to find changes to settings:
#find . -mmin -1 -type f -exec ls -l {} +
# ** OR
# $defaults read > before
# $defaults read > after
# code --diff before after

###############################################################################
# Sudo                                                                        #
###############################################################################
echo "Enter admin password if prompted"
sudo -v #-v adds 5 minutes https://www.sudo.ws/man/1.8.13/sudo.man.html

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Homebrew                                                                    #
###############################################################################
# Install homebrew if not already installed
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
   echo "Homebrew already installed"
fi

curl -o brewfile https://raw.githubusercontent.com/jonathanstanley/gosh/master/brewfile
brew bundle --no-lock
rm -f brewfile

#https://github.com/mathiasbynens/dotfiles/blob/master/.osx
#https://dotfiles.github.io/
###############################################################################
# General UI/UX                                                               #
###############################################################################
# Close System Preferences panes to avoid overriding this script
osascript -e 'tell application "System Preferences" to quit'

#Show battery percent in system tray
defaults write com.apple.menuextra.battery ShowPercent true

# Enable lid wakeup
sudo pmset -a lidwake 1

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  
# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable Notification Center and remove the menu bar icon
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# Stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# Disable automatic autocorrect (annoying when typing code)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable recent items
defaults write -g NSNavRecentPlacesLimit -int 0

# Disable language / flag input menu in menu bar
defaults write com.apple.TextInputMenu visible -bool false

# Disable startup chime (revert with sudo nvram StartupMute=%00)
sudo nvram StartupMute=%01

# Hide extra icons in menu bar
#remove wifi icon (available in bento box)
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -int 0 
#remove spotlight search icon (use cmd+space)
defaults write com.apple.controlcenter "NSStatusItem Visible Item-0" -int 0; 

###############################################################################
# Set a standard user picture from a URL                                      #
###############################################################################
#Use the picture from this GitHub account
sudo curl -o "/Library/User Pictures/user_picture.png" $USERPICTURE
user_picture="/Library/User Pictures/user_picture.png"
if [ -f "$user_picture" ]
then
	#remove existing user picture
	sudo -u $USER dscl . delete /Users/$USER jpegphoto
	sudo -u $USER dscl . delete /Users/$USER Picture
	#set new user picture
	sudo dscl . create /Users/$USER Picture "$user_picture"
else
	echo "Failed to set:" $user_picture 
fi

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################
# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Screen                                                                      #
###############################################################################
# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################
# Set the default `PfDe` location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show hidden files by default (easy enough to toggle with cmd+shift+.)
# defaults write com.apple.Finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show the ~/Library folder
#chflags nohidden ~/Library

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: remove color tags
defaults write com.apple.finder ShowRecentTags -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use column view in all Finder windows by default
# Four-letter codes for the view modes: `icnv` = icon, `clmv` = column, `Flwv` = coverflow, `Nlsv` = list
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Show items in finder sidebar
defaults write com.apple.sidebarlists systemitems -dict-add ShowEjectables -bool true
defaults write com.apple.sidebarlists systemitems -dict-add ShowHardDisks -bool false
defaults write com.apple.sidebarlists systemitems -dict-add ShowRemovable -bool false
defaults write com.apple.sidebarlists systemitems -dict-add ShowServers -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Expand the “General”, “Open with”, and “Sharing & Permissions” File Info panes
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true
  
# Show the /Volumes folder
sudo chflags nohidden /Volumes

# Set sidebar favorites
#https://github.com/mosen/mysides
# //not working on Apple silicon
# mysides add $USER file:///Users/$USER/
# mysides remove myDocuments.cannedSearch
# mysides remove Applications
# mysides remove Desktop
# mysides remove Documents

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################
# Minimize windows into their application’s icon
#defaults write com.apple.dock minimize-to-application -bool true

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don't show recent applications in the Dock
defaults write com.apple.dock show-recents -bool false

# Disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Reset Launchpad, but keep the desktop wallpaper intact
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

###############################################################################
# Time Machine                                                                #
###############################################################################
# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups
sudo tmutil disablelocal
sudo tmutil disable #big sur

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Google Chrome                                                               #
###############################################################################

# Use the system-native print preview dialog
#defaults write com.google.Chrome DisablePrintPreview -bool true

# Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true

# Disable dark mode (indistinguishable from incognito)
# defaults write com.google.Chrome NSRequiresAquaSystemAppearance -bool YES

###############################################################################
# Security                                                                    #
###############################################################################
# Disable the “are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

#Set security for HIPAA compliance
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/hipaacert/macos-hipaa/master/comply.sh)"

# Add lost/found notice on Login Window
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "${LOSTFOUNDTEXT}"
