#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mysql
mysqldump --single-transaction --set-gtid-purged=OFF --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_USER" --password="$PLATFORM_MYSQL_PASSWORD" --databases $PLATFORM_MYSQL_DATABASES | gzip > $folder/mysql.gz

# Cipher
openssl aes-256-cbc -md sha256 -salt -out $folder/mysql.gz.enc -in $folder/mysql.gz -pass pass:"$BACKUP_PASSWORD" || true
rm $folder/mysql.gz

echo "Uploading to NAS"
rclone copy $folder/mysql.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME/mysql
  mv $folder/mysql.gz.enc $HOST_MOUNT/$PLATFORM_NAME/mysql
else
  rm -rf $folder/mysql.gz.enc
fi
