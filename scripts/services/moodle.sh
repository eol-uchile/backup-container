#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump Moodle data
tar -zcf $folder/moodle.tar.gz $PLATFORM_MOODLE_DATA || rm -fv $folder/moodle.tar.gz

# Cipher
if [ -f $folder/moodle.tar.gz ]
then
  openssl aes-256-cbc -md sha256 -salt -out $folder/moodle.tar.gz.enc -in $folder/moodle.tar.gz -pass pass:"$BACKUP_PASSWORD" || rm -fv $folder/moodle.tar.gz.enc
  if [ -f $folder/moodle.tar.gz.enc ]
  then
    echo "Uploading to NAS"
    rclone copy $folder/moodle.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

    rm -rf $folder/moodle.tar.gz.enc
  else
    echo "Skipping uploading to NAS"
  fi
  rm $folder/moodle.tar.gz
else
  echo "Skipping ciphering"
fi

# # Clean or move to mount for recovery
# if [ $3 = 'keep' ]
# then
#   mkdir -p $HOST_MOUNT/$PLATFORM_NAME/moodle
#   mv $folder/moodle.tar.gz.enc $HOST_MOUNT/$PLATFORM_NAME/moodle
# else
#   rm -rf $folder/moodle.tar.gz.enc
# fi
