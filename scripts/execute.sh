#!/usr/bin/env bash

set -eu
folder=$1
mkdir -p $folder

# Dump mysql
mysqldump --single-transaction --set-gtid-purged=OFF --host="$PLATFORM_MYSQL_HOST" --port=$PLATFORM_MYSQL_PORT --user="$PLATFORM_MYSQL_USER" --password="$PLATFORM_MYSQL_PASSWORD" --databases $PLATFORM_MYSQL_DATABASES | gzip > $folder/mysql.gz

# Dump postgresql
pg_dump --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" --password="$PLATFORM_POSTGRESQL_PASSWORD" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz

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
  rclone copy --ignore-errors --ignore-checksum --transfers 16 source:$i destination:$i || true
done

kill $MINIO_PID

tar -zcf $folder/s3.tar.gz /tmp/s3/ --remove-files
rm -rf /tmp/s3
