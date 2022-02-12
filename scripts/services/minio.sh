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
  rclone copy --ignore-errors --ignore-checksum --transfers 16 source:$i destination:$i || true
done

kill $MINIO_PID

echo "Uploading to NAS"
rclone copy $HOST_MOUNT/$PLATFORM_NAME/minio nasencrypted:/share/eol_backup/$PLATFORM_NAME/$remote_folder/minio

# Clean or move to mount for recovery
if [ $3 = 'keep' ]
then
  mkdir -p $HOST_MOUNT/$PLATFORM_NAME
  mv $HOST_MOUNT/$PLATFORM_NAME/minio $HOST_MOUNT/$PLATFORM_NAME
else
  rm -rf $HOST_MOUNT/$PLATFORM_NAME/minio
fi
