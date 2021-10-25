#!/usr/bin/env bash

echo "Starting backup"
set -eu

# Configure
sh /root/scripts/configure.sh

# Daily or hourly
option=$1

BASE=/tmp/backup
datenow=$( [ $option == 'daily' ] && echo $(date +%Y%m%d) || echo $(date +%H) )
folder=$BASE/$datenow
mkdir -p $folder

outfolder=$option/$datenow

echo "mkdir done"

# Save delete folders paremeter
clean_disk=$3

# Run backups
backups=$(echo $2 | sed "s/,/ /g")
for s in $backups; do
  echo "Doing $s"
  sh /root/scripts/services/$s.sh $folder $outfolder $clean_disk
done;

rm -fr $BASE
