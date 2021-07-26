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

outfolder=$option/

echo "mkdir done"

# Run backups
backups=$(ls /root/scripts/services/)
for s in $backups; do
  echo "Doing $s"
  sh /root/scripts/services/$s $folder $outfolder
done;

rm -fr $BASE
