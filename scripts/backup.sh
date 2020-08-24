#!/usr/bin/env bash

echo "Starting backup"
set -eu

source /root/env/config.env
export PATH=$PATH:/usr/local/bin/

BASE=/tmp/backup
datenow=$(date +%Y%m%d)
folder=$BASE/$datenow
mkdir -p $folder

echo "mkdir done"

# Run backups
sh /root/scripts/uabierta.sh $folder

# Copy to nfs
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true

rm -fr $BASE
