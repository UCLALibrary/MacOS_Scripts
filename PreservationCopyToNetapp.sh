#!/bin/bash

# Written in 2018 by Jonathan Wilson, UCLA Library
#
# Purpose: combine existing workflows related to
# copying digitized files to long-term network storage
# The script is divided into 4 sections:
#     1: get and verify user input
#     2: create md5 sidecar files
#     3: copy files to remote directory
#     4: compare file checksums
#
# Logs are saved to user's desktop
log_location="$HOME/Desktop"

#-----------------------------
# SECTION 1: USER INPUTS PATHS
#-----------------------------
# prompt user for source path
# check to see if source exists as directory
echo -n "Enter source path: "
read dir_source
if [[ ! -d "$dir_source" ]]; then
  echo "Source directory does not exist, exiting";
  exit 1;
fi
# check if directories reside inside the source, if so exit
dir_count=$(find "$dir_source" -type d | wc -l)
if [[ $dir_count -ge 2 ]]; then
  echo -e "   Subdirectories detected!\n   Please select a single directory containing only files.\n   Exiting."
  exit 1
fi

# prompt user for destination path
# check to see if destination exists as directory
echo -n "Enter destination directory: "
read dir_remote
if [ ! -d "$dir_remote" ]; then
  echo "Destination directory does not exist, exiting";
  exit 1;
fi

# request user to confirm the action
#echo "Continue? (y/n): "

# get current time to use in time stamp and run time
start_datetime=$(date +%Y-%m-%d_%H-%M-%S)
epoch_start=$(date +%s)
#create log file
log_file="$log_location/prvcpylog_$start_datetime.txt"
>> $log_file
# write start time and action to log file
echo -e "Script started at " $start_datetime " by " $USER "\n" >> $log_file
echo -e "~~~ACTION~~~\n" | tee -a $log_file
echo -e  $dir_source "\n  will be copied to \n" $dir_remote "\n" | tee -a $log_file

#-----------------------------------------
# SECTION 2: CREATE CHECKSUM SIDECAR FILES
#-----------------------------------------
echo -e "~~~CREATE SIDECAR FILES~~~\n" | tee -a $log_file
# read file list into an array
filelist_src=(`find "$dir_source" -type f ! -name "\.*" ! -name "Thumbs.db"`)

# create .md5 file for each file in source directory
cd $dir_source
counter=0
for file in ${filelist_src[@]}; do
    if [[ ( ! -d $file ) && (! ${file: -4} == ".md5") ]]; then
    filename="$(basename "$file")";
    # only create the sidecar file if it does not already exist
    if [[ ! -f "$filename".md5 ]]; then
      md5 "$filename" > "$filename".md5
      echo $filename >> $log_file
      counter=$((counter + 1))
    fi
  fi
done
echo -e "$counter sidecar files created.\n" | tee -a $log_file

#----------------------------------------
# SECTION 3: COPY FILES TO REMOTE STORAGE
#----------------------------------------
echo -e "~~~COPY DIRECTORY~~~\n" | tee -a $log_file
rsync -achv "$dir_source" "$dir_remote" --exclude .DS_Store | tee -a $log_file

echo -e "\n" | tee -a $log_file

#-----------------------------
# SECTION 4: COMPARE CHECKSUMS
#-----------------------------
echo -e "~~~COMPARE COPIED FILE CHECKSUMS~~~\n" | tee -a $log_file
echo -e "(sidecar | calculated) \n" | tee -a $log_file
cd $dir_remote
counter=0

# read just-copied list into an array
filelist_remote=(`find "$dir_remote" -type f ! -name "\.*" ! -name "Thumbs.db"`)

# calculate checksum for each file in remote directory and compare to the sidecar file
for file in ${filelist_remote[@]}; do
  if [[ ( ! -d $file ) && (! ${file: -4} == ".md5") ]]; then
    filename="$(basename "$file")"
    # calculate checksum for the copied original file
    md5_calculated="$(md5 $file | awk -F "= " '{print$2}')"
    # get the checksum from the sidecar file
    md5_sidecar="$(awk -F "= " '{print$2}' < $file.md5)"
    # print both checksums to the log along with the filename
    echo -e $filename "\n" $md5_calculated "|" $md5_sidecar | tee -a $log_file
    if [[ $md5_sidecar != $md5_calculated ]]; then
      echo "ERROR - CHECKSUMS FOR $filename DO NOT MATCH" | tee -a $log_file
      counter=$((counter +1))
    fi
    echo -e "\n"
  fi
done

#-----------------------------
# WRAP UP
#-----------------------------
# calculate run time and write to log before exiting
end_datetime=$(date +%Y-%m-%d_%H-%M-%S)
epoch_end=$(date +%s)
script_run_time=$(( $epoch_end - $epoch_start ))

# format script run time into more human readable format
function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

# display additional message if there were any checksum errors
if [[ counter -gt 0 ]]; then
  echo -e "   ********************************************\n \
  $counter Checksum errors detected - check log file!\n \
  ********************************************\n "
fi

echo -e "\nScript finished at " $end_datetime " after " $(displaytime $script_run_time) | tee -a $log_file
exit 0
