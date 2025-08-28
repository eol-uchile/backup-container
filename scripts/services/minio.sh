#!/usr/bin/env bash

set -eu
folder=$1
remote_folder=$2

# Dump s3
mkdir -p $HOST_MOUNT/$PLATFORM_NAME/minio

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  echo "============================== STARTED BUCKET ${i} ============================="
  rclone sync --checksum target:$i $HOST_MOUNT/$PLATFORM_NAME/minio/$i
  echo "============================== FINISHED BUCKET ${i} ============================="
done

# Compress folder
tar -zcf $folder/s3.tar.gz --directory=$HOST_MOUNT/$PLATFORM_NAME minio

# Cipher & delete source
sh /root/scripts/cipher.sh $folder/s3.tar.gz $folder/s3.tar.gz.enc

echo "Uploading to NAS"
# Copy compressed&encrypted file
rclone copy $folder/s3.tar.gz.enc nas:/share/eol_backup/$PLATFORM_NAME/$remote_folder
echo "Uploaded to NAS"

# Remove compressed&encrypted file
rm -rf $folder/s3.tar.gz.enc
