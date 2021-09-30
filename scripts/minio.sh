#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump s3
mkdir -p /tmp/s3
minio server /tmp/s3 &
MINIO_PID=$!

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  rclone copy --ignore-errors --ignore-checksum --transfers 16 source:$i destination:$i || true
done

kill $MINIO_PID

tar -zcf $folder/s3.tar.gz /tmp/s3/ --remove-files
rm -rf /tmp/s3

# Cipher
openssl aes-256-cbc -md sha256 -salt -out $folder/s3.tar.gz.enc -in $folder/s3.tar.gz -pass pass:"$BACKUP_PASSWORD" 
rm $folder/s3.tar.gz

echo "Uploading to NAS"
rclone copy $folder/s3.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder

rm -rf $folder/s3.tar.gz.enc