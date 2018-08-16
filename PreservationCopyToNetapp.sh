#!/bin/bash

# Written in 2018 by Jonathan Wilson, UCLA Library
#
# Purpose: combine existing workflows related to
# copying digitized files to long-term network storage
# The script is divided into XXX sections:
#     1: user input
#     2: create md5 sidecar files
#     3: copy files to remote directory
#     4: compare file hashes
#
#
# Logs are saved to user's desktop
log_location="$HOME/Desktop"

# SECTION 1: USER INPUTS PATHS
# prompt user for source and destination paths
# check to see if paths exist as directories
echo -n "Enter source path: "
read dir_source
if [ ! -d "$dir_source" ]; then
  echo "Source directory does not exist, exiting";
  exit 1;
fi

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

# SECTION 2: CREATE CHECKSUM SIDECAR FILES
# read file list into an array
filelist_src=(`find "$dir_source" -type f ! -name "\.*" ! -name "Thumbs.db"`)

# for each file (except .md5 files), create .md5 file in same directory
cd $dir_source
for file in ${filelist_src[@]}; do
    if [[ ( ! -d $file ) && (! ${file: -4} == ".md5") ]]; then
    filename="$(basename "$file")";
    md5 "$filename" > "$filename".md5;
#    echo $file >> $log_file
  fi
done
echo -e "sidecar files created?\n" >> $log_file


# SECTION 3: COPY FILES TO REMOTE STORAGE
rsync -achv $dir_source $dir_remote --exclude .DS_Store | tee -a $log_file

echo "" >> $log_file

# SECTION 4: COMPARE CHECKSUMS
# remote directory only
# run checksums on all non-md5 files, compare them to content in actual md5 file


# calculate total time and write to log before exiting
end_datetime=$(date +%Y-%m-%d_%H-%M-%S)
epoch_end=$(date +%s)

script_run_time=$(( $epoch_end - $epoch_start ))
echo "Script finished at " $end_datetime " after " $script_run_time " seconds." >> $log_file

exit 0
