#!/bin/bash

# Written in 2018 by Jonathan Wilson, UCLA Library
#
# Purpose: combine existing workflows related to
# copying digitized files to long-term network storage
# The script is divided into XXX sections:
#     1: get and verify user input
#     2: create md5 sidecar files
#     3: copy files to remote directory
#     4: compare file hashes
#
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
echo $dir_source " will be copied to " $dir_remote
#echo "Continue? (y/n): "

# get current time to use in time stamp
start_datetime=$(date +%Y-%m-%d_%H-%M-%S)
epoch_start=$(date +%s)
#create log file
log_file="$log_location/prvcpy_$start_datetime.txt"
>> $log_file
# write start time to log file
echo -e "Script started at " $start_datetime " by " $USER "\n" >> $log_file

#-----------------------------------------
# SECTION 2: CREATE CHECKSUM SIDECAR FILES
#-----------------------------------------
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
rsync -achv "$dir_source" "$dir_remote" --exclude .DS_Store | tee -a $log_file

echo "" >> $log_file

#-----------------------------
# SECTION 4: COMPARE CHECKSUMS
#-----------------------------
# remote directory only
# run checksums on all non-md5 files, compare them to content in actual md5 file


# calculate total time and write to log before exiting
end_datetime=$(date +%Y-%m-%d_%H-%M-%S)
epoch_end=$(date +%s)

script_run_time=$(( $epoch_end - $epoch_start ))

echo "Script finished at " $end_datetime " after " $script_run_time " seconds." >> $log_file

exit 0
