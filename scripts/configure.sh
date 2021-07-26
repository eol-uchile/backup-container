#!/usr/bin/env bash

set -eu

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

[gdrive]
type = drive
client_id = $PLATFORM_GRIVE_CLIENT_ID
client_secret = $PLATFORM_GDRIVE_CLIENT_SECRET
scope = $PLATFORM_GDRIVE_SCOPE
token = $PLATFORM_GDRIVE_TOKEN
EOF