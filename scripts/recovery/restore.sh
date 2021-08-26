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
# - mongodb_edxapp.gz
# - mongodb_cs_comment_service.gz

# MySQL
zcat mysql.gz | mysql --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_ROOT_USER" --password="$PLATFORM_MYSQL_ROOT_PASSWORD"

# MongoDB (Add --drop to purge old data)
zcat mongodb_edxapp.gz | mongorestore --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username edxapp --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --db edxapp --archive --drop
zcat mongodb_cs_comment_service.gz | mongorestore --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username cs_comments_service --password "$PLATFORM_MONGODB_CS_PASSWORD" --authenticationDatabase cs_comments_service --db cs_comments_service --archive --drop

# Start minio
if [ $option == 'remote' ]
then
  tar -xf s3.tar.gz -C /restore
  minio server /restore/tmp/s3 &
else
  tar -xf s3.tar.gz
  minio server $backup_dir/tmp/s3 &
fi

# Sync s3 files
mkdir -p /root/.config/rclone
cat <<EOF >> /root/.config/rclone/rclone.conf
[source]
type = s3
env_auth = false
access_key_id = minio
secret_access_key = localminiosecret
region = us-east-1
endpoint = http://127.0.0.1:9000
location_constraint =
server_side_encryption =
[destination]
type = s3
env_auth = false
access_key_id = $PLATFORM_S3_ACCESS_KEY
secret_access_key = $PLATFORM_S3_SECRET_KEY
region = us-east-1
endpoint = $PLATFORM_S3_URL
location_constraint =
server_side_encryption =
EOF

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  echo "Syncing $i"
  rclone sync source:$i destination:$i
done

