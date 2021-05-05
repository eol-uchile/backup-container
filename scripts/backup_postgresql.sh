#!/usr/bin/env bash

echo "Starting backup"
set -eu

BASE=/tmp/backup-psql
datenow=$(date +%Y%m%d)
folder=$BASE/$datenow
mkdir -p $folder

echo "mkdir done"

# Dump postgresql
if [[ -z "${PLATFORM_POSTGRESQL_HOST}" ]]; then
  echo "Skipping POSTGRESQL";
else
  pg_dump --host="$PLATFORM_POSTGRESQL_HOST" --port=$PLATFORM_POSTGRESQL_PORT --username="$PLATFORM_POSTGRESQL_USER" $PLATFORM_POSTGRESQL_DATABASES | gzip > $folder/postgresql.gz
fi

# Copy to nfs
if [ -d /volume/nfs ]
then
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
fi

# Copy to gdrive
cat <<EOF >> /root/.config/rclone/rclone.conf
[gdrive]
type = drive
client_id = $PLATFORM_GRIVE_CLIENT_ID
client_secret = $PLATFORM_GDRIVE_CLIENT_SECRET
scope = $PLATFORM_GDRIVE_SCOPE
token = $PLATFORM_GDRIVE_TOKEN
EOF

rclone copy $BASE gdrive:/$PLATFORM_NAME/daily

rm -fr $BASE
