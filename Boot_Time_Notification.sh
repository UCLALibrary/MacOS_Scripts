#!/bin/bash

# Jonathan Wilson, April 2019
# 
# Displays an alert to the user if the last boot time is over X days. 
#
# The script checks the boot time before displaying a jamf helper alert,
#  in case the user has rebooted since the last inventory update. 
# The policy in Jamf Pro is scoped to a smart group for computers that
# last booted over 30 days ago (an extension attribute)
#

# Threshold to display alert - should match smart group in Jamf Pro
numberOfDays=30
# How long to display the alert before it times out, such as when the computer is locked
timeoutSeconds=300

# Get last boot time and format it to display in the alert
bootTimeEpoch=$( sysctl kern.boottime | awk '{print $5}' | tr -d , )
bootTimeFormatted=$( date -jf %s $bootTimeEpoch +%m/%d/%Y )

# Calculate number of days since last boot time
timeNowEpoch=$( date +%s )
daysDiff=$( echo $(( ($timeNowEpoch - $bootTimeEpoch)/86400 )))

# Set jamf helper text fields
alert_title="Message from DIIT"
alert_desc="Please restart at your earliest convenience.    This computer was last booted on $bootTimeFormatted and should be restarted to ensure consistent performance."

# Check to see if computer has been rebooted since being added to the smart group
if [ $daysDiff -ge $numberOfDays ]
then
	start=$(date +%s)
	# Display alert using jamf helper tool
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "$alert_title" -description "$alert_desc" -button1 "OK" -timeout $timeoutSeconds
	echo ""
	end=$(date +%s)
	# Calculate the time the alert was on screen to determine 
	# if the  timeout was reached or a button was pressed
	elapsed=$(( $end - $start ))
	if [ $elapsed -ge $timeoutSeconds ]
	then
		echo "timeout was reached"
	else
		echo "time elapsed: $elapsed seconds"
	fi
else
	echo "Last boot on $bootTimeFormatted. No alert shown."
fi