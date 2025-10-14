#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump s3
mkdir -p $HOST_MOUNT/$PLATFORM_NAME/minio
minio server $HOST_MOUNT/$PLATFORM_NAME/minio &
MINIO_PID=$!

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  echo "============================== STARTED BUCKET ${i} ============================="
  rclone copy --s3-disable-checksum --ignore-errors --ignore-checksum  --transfers 16 source:$i destination:$i
  echo "============================== FINISHED BUCKET ${i} ============================="
done

kill $MINIO_PID
# Compress folder
tar -zcf $folder/s3.tar.gz $HOST_MOUNT/$PLATFORM_NAME/minio

# Cipher
openssl aes-256-cbc -md sha256 -salt -out $folder/s3.tar.gz.enc -in $folder/s3.tar.gz -pass pass:"$BACKUP_PASSWORD"

# Remove compressed file
rm $folder/s3.tar.gz

echo "Uploading to NAS"
# Copy compressed&encrypted file
rclone copy $folder/s3.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

# Remove compressed&encrypted file
rm -rf $folder/s3.tar.gz.enc
