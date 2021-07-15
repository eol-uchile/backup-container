#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump
if [[ -z "${PLATFORM_POSTGRESQL_HOST}" ]]; then
  echo "Skipping POSTGRESQL";
else
  pg_dump --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz
  # Copy to nfs
  if [ -d /volume/nfs ]
  then
  tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
  fi
  rclone copy $folder gdrive:/$PLATFORM_NAME/$remote_folder
  rm -fr $folder/postgresql.gz
fi