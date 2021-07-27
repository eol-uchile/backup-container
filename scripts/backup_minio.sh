#!/usr/bin/env bash

# Minio takes to long to create a backup. This should only do daily
# routines to avoid cluster cpu throtling.

echo "Starting backup"
set -eu

# Configure
sh /root/scripts/configure.sh

# Daily
BASE=/tmp/backup
datenow=$(date +%Y%m%d)
folder=$BASE/$datenow
mkdir -p $folder

outfolder=$option/$datenow

echo "mkdir done"

# Run minio backup
echo "Doing Minio Backups"
sh /root/scripts/minio.sh $folder $outfolder

rm -fr $BASE