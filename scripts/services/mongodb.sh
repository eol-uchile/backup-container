#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
if [ -z ${PLATFORM_MONGODB_USER+xyz} ]
then
  mongodump --host="$PLATFORM_MONGODB_HOST" --port=$PLATFORM_MONGODB_PORT --db="$PLATFORM_MONGODB_DB" --gzip --archive=$folder/mongodb_openedx.gz
else
  mongodump --host="$PLATFORM_MONGODB_HOST" --port=$PLATFORM_MONGODB_PORT --username="$PLATFORM_MONGODB_USER" --password="$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase="$PLATFORM_MONGODB_DB" --db="$PLATFORM_MONGODB_DB" --gzip --archive=$folder/mongodb_openedx.gz
fi

# Cipher & delete source
/root/scripts/cipher.sh $folder/mongodb_openedx.gz $folder/mongodb_openedx.gz.enc

echo "Uploading to NAS"
rclone copy $folder/mongodb_openedx.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME/mongodb
  mv $folder/mongodb_openedx.gz.enc $HOST_MOUNT/$PLATFORM_NAME/mongodb
else
  rm -rf $folder/mongodb_openedx.gz.enc
fi
