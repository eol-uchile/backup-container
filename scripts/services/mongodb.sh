#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
mongodump --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --archive --db edxapp | gzip > $folder/mongodb_edxapp.gz

openssl aes-256-cbc -md sha256 -salt -out $folder/mongodb_edxapp.gz.enc -in $folder/mongodb_edxapp.gz -pass pass:"$BACKUP_PASSWORD"
rm $folder/mongodb_edxapp.gz

echo "Uploading to NAS"
rclone copy $folder/mongodb_edxapp.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME
  mv $folder/mongodb_edxapp.gz.enc $HOST_MOUNT/$PLATFORM_NAME
else
  rm -rf $folder/mongodb_edxapp.gz.enc
fi