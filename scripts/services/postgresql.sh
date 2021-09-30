#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump
if [[ -z $PLATFORM_POSTGRESQL_HOST ]]; then
  echo "Skipping POSTGRESQL";
else
  pg_dump --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz
  openssl aes-256-cbc -md sha256 -salt -out $folder/postgresql.gz.enc -in $folder/postgresql.gz -pass pass:"$BACKUP_PASSWORD"
  rm $folder/postgresql.gz
  echo "Uploading NAS"
  rclone copy $folder/postgresql.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
  rm $folder/postgresql.gz.enc
fi