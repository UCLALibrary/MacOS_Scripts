#!/bin/bash

######################################################
# 
# Jonathan Wilson, 2019
# 
# This script is designed to run after Microsoft Office
# is installed, in order to set initial defaults. 
# All plists are written to /Library/Preferences to affect
# all users on the computer.
# Preference info can be found at macadmins.software 
# 
######################################################

########################################
# Set global settings 
########################################

# surpress first run windows
/usr/bin/defaults write /Library/Preferences/com.microsoft.office OfficeAutoSignIn -bool TRUE

# accept eula on behalf of user
/usr/bin/defaults write /Library/Preferences/com.microsoft.office TermsAccepted1809 -bool TRUE

# select "Colorful" theme so user doesn't have to
/usr/bin/defaults write /Library/Preferences/com.microsoft.office kCUIThemePreferencesThemeKeyPath -int 0

# disable whats new dialogs
/usr/bin/defaults write /Library/Preferences/com.microsoft.office ShowWhatsNewOnLaunch -bool FALSE

# use local drive instead of onedrive as default for saving documents
/usr/bin/defaults write /Library/Preferences/com.microsoft.office DefaultsToLocalOpenSave -bool TRUE

# Open new file on launch, don't show template options
# /usr/bin/defaults write /Library/Preferences/com.microsoft.office ShowDocStageOnLaunch -bool FALSE
# commented out, because the app just shows nothing if this preference is set

#######################################################
# Set auto update settings
# App registration for MAU is set with a config profile
#######################################################

# automatically download and install updates
/usr/bin/defaults write /Library/Preferences/com.microsoft.autoupdate2 HowToCheck -string ‘AutomaticDownload’


########################################
# Set Outlook settings
########################################

# Suppress autoredirect dialogs
/usr/bin/defaults write /Library/Preferences/com.microsoft.Outlook TrustO365AutodiscoverRedirect -bool TRUE

