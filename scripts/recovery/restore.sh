#!/usr/bin/env bash

# 
# Use local or remote backups to restore an OpenEdx Instance
# 
# Notes: This assumes that the instance is using ES7
# and MongoDB 4 to complete the restoration process
#

echo "Starting recovery phase"
set -eu

option=$1 # local or remote
# If backup is remote operations will be done from /restore
# Else at the backup_dir (using an absolute route)
backup_dir=$2

# Configure
sh /root/scripts/configure.sh

if [ $option == 'remote' ]
then
  # Clone remote backup
  rclone copy backup:$backup_dir /restore
  cd /restore
else
  cd $backup_dir
fi

# Since the backup format is standardized this assumes the following files
# - mysql.gz
# - s3.tar.gz
# - mongodb_openedx.gz

# MySQL
zcat mysql.gz | mysql --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_ROOT_USER" --password="$PLATFORM_MYSQL_ROOT_PASSWORD"

# MongoDB (Add --drop to purge old data)
zcat mongodb_openedx.gz | mongorestore --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase "$PLATFORM_MONGODB_DB" --db "$PLATFORM_MONGODB_DB" --archive --drop

# Start minio
if [ $option == 'remote' ]
then
  tar -zxf s3.tar.gz -C /restore
  cd /restore
else
  tar -zxf s3.tar.gz
  cd ./minio
fi

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  echo "Syncing $i"
  rclone sync ./$i target:$i
done

