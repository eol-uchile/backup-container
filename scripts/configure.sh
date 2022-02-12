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
access_key_id = $MINIO_ROOT_USER
secret_access_key = $MINIO_ROOT_PASSWORD
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

[nas]
type = sftp
host = $NAS_HOST
user = $NAS_USER
pass = $NAS_PASS
key_file_pass = $NAS_KEY_FILE_PASS
md5sum_command = md5sum
sha1sum_command = sha1sum

[nasencrypted]
type = crypt
remote = nas:
filename_encryption = off
directory_name_encryption = false
password = $NAS_ENCRYPTED_FILE_KEY

EOF
