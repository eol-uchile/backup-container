#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump Moodle data
tar -zcf $folder/moodle.tar.gz $PLATFORM_MOODLE_DATA || rm -fv $folder/moodle.tar.gz

if [ -f $folder/moodle.tar.gz ]
then
  # Cipher & delete source
  sh /root/scripts/cipher.sh $folder/moodle.tar.gz $folder/moodle.tar.gz.enc
  if [ -f $folder/moodle.tar.gz.enc ]
  then
    echo "Uploading to NAS"
    rclone copy $folder/moodle.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

    rm -rf $folder/moodle.tar.gz.enc
  else
    echo "Skipping uploading to NAS"
  fi
else
  echo "Skipping ciphering"
fi
