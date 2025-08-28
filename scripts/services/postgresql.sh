#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump
pg_dump --clean --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz || rm -fv $folder/postgresql.gz
if [ -f $folder/postgresql.gz ] && [ -s $folder/postgresql.gz ]
then
  # Cipher & delete source
  sh /root/scripts/cipher.sh $folder/postgresql.gz $folder/postgresql.gz.enc
  if [ -f $folder/postgresql.gz.enc ]
  then
    echo "Uploading to NAS"
    rclone copy $folder/postgresql.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
    echo "Uploaded to NAS"

    # Clean or move to mount for recovery
    if [ $3 = 'keep' ]
    then
      mkdir -p $HOST_MOUNT/$PLATFORM_NAME
      mv $folder/postgresql.gz.enc $HOST_MOUNT/$PLATFORM_NAME
    else
      rm $folder/postgresql.gz.enc
    fi
  else
    echo "Skipping uploading to NAS"
  fi
else
  echo "Skipping ciphering"
fi
