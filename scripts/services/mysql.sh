#!/usr/bin/env bash

set -eu 
folder=$1
remote_folder=$2

# Dump mysql
mysqldump --single-transaction --set-gtid-purged=OFF --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_USER" --password="$PLATFORM_MYSQL_PASSWORD" --databases $PLATFORM_MYSQL_DATABASES | gzip > $folder/mysql.gz

# Copy to nfs
if [ -d /volume/nfs ]
then
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
fi

echo "Uploading to Drive"
rclone copy $folder gdrive:/$PLATFORM_NAME/$remote_folder

rm -fr $folder/mysql.gz