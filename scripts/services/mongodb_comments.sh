#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
mongodump --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --archive --db cs_comments_service | gzip > $folder/mongodb_cs_comment_service.gz

openssl aes-256-cbc -md sha256 -salt -out $folder/mongodb_cs_comment_service.gz.enc -in $folder/mongodb_cs_comment_service.gz -pass pass:"$BACKUP_PASSWORD"
rm $folder/mongodb_cs_comment_service.gz

echo "Uploading to NAS"
rclone copy $folder/mongodb_cs_comment_service.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME/mongodb
  mv $folder/mongodb_cs_comment_service.gz.enc $HOST_MOUNT/$PLATFORM_NAME/mongodb
else
  rm -rf $folder/mongodb_cs_comment_service.gz.enc
fi