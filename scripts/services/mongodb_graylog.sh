#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump mongodb
mongodump --host="$PLATFORM_MONGODB_HOST" --gzip --archive=$folder/mongodb_graylog.gz

# Cipher & delete source
sh /root/scripts/cipher.sh $folder/mongodb_graylog.gz $folder/mongodb_graylog.gz.enc

echo "Uploading to NAS"
rclone copy $folder/mongodb_graylog.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME/mongodb_graylog
  mv $folder/mongodb_graylog.gz.enc $HOST_MOUNT/$PLATFORM_NAME/mongodb_graylog
else
  rm -rf $folder/mongodb_graylog.gz.enc
fi
