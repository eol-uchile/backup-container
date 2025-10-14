#!/usr/bin/env bash

echo "Starting backup"
set -eu

# Configure
/root/scripts/configure.sh

# Daily or hourly
option=$1

BASE=/tmp/backup
datenow=$( [ $option == 'daily' ] && echo $(date +%Y%m%d) || echo $(date +%H) )
folder=$BASE/$datenow
mkdir -p $folder

outfolder=$option/$datenow

echo "mkdir done"

# Save delete folders paremeter
clean_disk=${3:-foo}

# Run backups
backups=$(echo $2 | sed "s/,/ /g")
for s in $backups; do
  echo "Doing $s"
  /root/scripts/services/$s.sh $folder $outfolder $clean_disk
  echo "Done $s"
done;

rm -fr $BASE
