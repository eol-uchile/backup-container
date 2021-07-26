#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
mongodump --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --archive --db cs_comments_service | gzip > $folder/mongodb_cs_comment_service.gz

# Copy to nfs
if [ -d /volume/nfs ]
then
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
fi

echo "Uploading to Drive"
rclone copy $folder gdrive:/$PLATFORM_NAME/$remote_folder

rm -fr $folder/mongodb_cs_comment_service.gz