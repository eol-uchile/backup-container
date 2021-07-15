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

# Copy to nfs
if [ -d /volume/nfs ]
then
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
fi

rclone copy $folder gdrive:/$PLATFORM_NAME/$remote_folder

rm -fr $folder/mongodb_cs_comment_service.gz