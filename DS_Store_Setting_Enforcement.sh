#!/bin/bash

# Written by Jonathan Wilson, April 2019 
#
# Uses a LaunchAgent to creates a plist file for each 
# user that tells Finder not to # add .DS_Store files 
# to network drives

mkdir /Users/Shared/diit

# Create script file in Users/Shared/diit
# The script will run the defaults command
cat << EOF > /Users/Shared/diit/set_dsstore_setting.sh
#!/bin/bash

/usr/bin/defaults write ~/Library/Preferences/com.apple.desktopservices.plist DSDontWriteNetworkStores -bool TRUE
EOF

sleep 1

cat << EOF > /Library/LaunchAgents/edu.ucla.library.dsstoresetting2.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>edu.ucla.library.dsstoresetting2</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Users/Shared/diit/set_dsstore_setting.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
EOF

sleep 1

chown root:wheel /Library/LaunchAgents/edu.ucla.library.dsstoresetting2.plist

chmod 644 /Library/LaunchAgents/edu.ucla.library.dsstoresetting2.plist

launchctl load /Library/LaunchAgents/edu.ucla.library.dsstoresetting2.plist
