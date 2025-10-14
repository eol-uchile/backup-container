#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump Moodle data
tar -zcf $folder/moodle.tar.gz $PLATFORM_MOODLE_DATA

# Cipher & delete source
/root/scripts/cipher.sh $folder/moodle.tar.gz $folder/moodle.tar.gz.enc

echo "Uploading to NAS"
rclone copy $folder/moodle.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

# Remove compressed&encrypted file
rm -rf $folder/moodle.tar.gz.enc
