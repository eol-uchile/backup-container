#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump
pg_dump --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz
openssl aes-256-cbc -md sha256 -salt -out $folder/postgresql.gz.enc -in $folder/postgresql.gz -pass pass:"$BACKUP_PASSWORD"
rm $folder/postgresql.gz

echo "Uploading to NAS"
rclone copy $folder/postgresql.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

# Clean or move to mount for recovery
if [ $3 = 'keep' ]
then
  mv $folder/postgresql.gz.enc $HOST_MOUNT
else
  rm $folder/postgresql.gz.enc
fi
