#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump Moodle data
tar -zcf $folder/moodle.tar.gz $PLATFORM_MOODLE_DATA

# Cipher
openssl aes-256-cbc -md sha256 -salt -out $folder/moodle.tar.gz.enc -in $folder/moodle.tar.gz -pass pass:"$BACKUP_PASSWORD"

# Remove compressed file
rm $folder/moodle.tar.gz

echo "Uploading to NAS"
rclone copy $folder/moodle.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

# Remove compressed&encrypted file
rm -rf $folder/moodle.tar.gz.enc
