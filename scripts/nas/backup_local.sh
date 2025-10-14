#!/usr/bin/env bash

# 
# Download remote backups from Drive
# to the local system
#

echo "Starting backup copy to local"
set -eu

# Configure
/root/scripts/configure.sh

# Daily or hourly
option=$1
out=$2

# Date should be in format 2014-06-28
init=$3
days=$4

if [ $option == 'daily' ]
then
  for i in $(eval echo {1..$days}); do 
    # custom format using +
    datenow=$(date +%Y%m%d -d "$init +$i days")
    remote_folder=$PLATFORM_NAME/$option/$datenow
    folder=$out/$remote_folder
    echo "Downloading $remote_folder from Drive"
    rclone copy gdrive:/$remote_folder $folder    
  done
else
  for i in {1..24}; do 
    remote_folder=$PLATFORM_NAME/$option/$i
    folder=$out/$remote_folder
    echo "Downloading $remote_folder from Drive"
    rclone copy gdrive:/$remote_folder $folder
  done
fi
