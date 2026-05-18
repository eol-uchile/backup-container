#!/usr/bin/env bash

set -euo pipefail
folder=$1
remote_folder=$2

# Dump mysql
attempt=1
while [ $attempt -le 3 ]; do
  echo "Attempt $attempt for mysql dump"
  if mysqldump --single-transaction --set-gtid-purged=OFF --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_USER" --password="$PLATFORM_MYSQL_PASSWORD" --databases $PLATFORM_MYSQL_DATABASES | gzip > $folder/mysql.gz; then
    break
  fi
  if [ $attempt -eq 3 ]; then
    echo "Mysql backup failed after 3 attempts"
    exit 1
  fi
  echo "Mysql backup failed, retrying in 30 seconds..."
  sleep 30
  attempt=$((attempt + 1))
done

# Cipher & delete source
/root/scripts/cipher.sh $folder/mysql.gz $folder/mysql.gz.enc

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
