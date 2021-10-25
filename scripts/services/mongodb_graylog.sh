#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
mongodump --host "$PLATFORM_MONGODB_HOST" --archive | gzip > $folder/mongodb_graylog.gz

openssl aes-256-cbc -md sha256 -salt -out $folder/mongodb_graylog.gz.enc -in $folder/mongodb_graylog.gz -pass pass:"$BACKUP_PASSWORD"
rm $folder/mongodb_graylog.gz

echo "Uploading to NAS"
rclone copy $folder/mongodb_graylog.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

if [ $3 = 'keep' ]
then
  mv -rf $folder/mongodb_graylog.gz.enc $HOST_MOUNT
else
  rm -rf $folder/mongodb_graylog.gz.enc
fi