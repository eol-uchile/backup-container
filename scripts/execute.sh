#!/usr/bin/env bash

set -eu
folder=$1
mkdir -p $folder

# Dump mysql
mysqldump --single-transaction --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_USER" --password="$PLATFORM_MYSQL_PASSWORD" --databases edxapp edxapp_csmh | gzip > $folder/mysql.gz

# Dump mongodb
mongodump --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --archive --db edxapp | gzip > $folder/mongodb_edxapp.gz
mongodump --host "$PLATFORM_MONGODB_HOST" --port $PLATFORM_MONGODB_PORT --username "$PLATFORM_MONGODB_USER" --password "$PLATFORM_MONGODB_PASSWORD" --authenticationDatabase edxapp --archive --db cs_comments_service | gzip > $folder/mongodb_cs_comment_service.gz

# Configure rclone
mkdir -p /root/.config/rclone
cat <<EOF >> /root/.config/rclone/rclone.conf
[source]
type = s3
env_auth = false
access_key_id = $PLATFORM_S3_ACCESS_KEY
secret_access_key = $PLATFORM_S3_SECRET_KEY
region = us-east-1
endpoint = $PLATFORM_S3_URL
location_constraint =
server_side_encryption =

[destination]
type = s3
env_auth = false
access_key_id = $MINIO_ACCESS_KEY
secret_access_key = $MINIO_SECRET_KEY
region = us-east-1
endpoint = http://localhost:9000
location_constraint =
server_side_encryption =
EOF

# Dump s3
mkdir -p /tmp/s3
minio server /tmp/s3 &
MINIO_PID=$!

for i in $(echo $PLATFORM_S3_BUCKETS | sed "s/,/ /g")
do
  rclone copy --transfers 64 source:$i destination:$i
done

kill $MINIO_PID

tar -zcf $folder/s3.tar.gz /tmp/s3/
rm -rf /tmp/s3
