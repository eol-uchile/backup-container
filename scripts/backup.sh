#!/usr/bin/env bash

echo "Starting backup"
set -eu

source /root/env/config.env
export PATH=$PATH:/usr/local/bin/

BASE=/tmp/backup
datenow=$(date +%Y%m%d)
folder=$BASE/$datenow
mkdir -p $folder

echo "mkdir done"

# Run backups
sh /root/scripts/execute.sh $folder

# Copy to nfs
if [ -d /volume/nfs ]
then
tar -cf - $folder | openssl aes-256-cbc -md sha256 -salt -out /volume/nfs/$PLATFORM_NAME/daily/$datenow.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
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
