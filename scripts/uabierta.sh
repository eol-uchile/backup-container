#!/usr/bin/env bash

set -eu
folder=$1/uabierta
mkdir -p $folder

# Dump mysql
mysqldump --single-transaction --host="$UABIERTA_MYSQL_HOST" --user="$UABIERTA_MYSQL_USER" --password="$UABIERTA_MYSQL_PASSWORD" --databases edxapp edxapp_csmh | gzip > $folder/mysql.gz

# Dump mongodb
mongodump --host "$UABIERTA_MONGODB_HOST" --username "$UABIERTA_MONGODB_USER" --password "$UABIERTA_MONGODB_PASSWORD" --authenticationDatabase "$UABIERTA_MONGODB_CONTENTSTORE" --archive --db $UABIERTA_MONGODB_CONTENTSTORE | gzip > $folder/mongodb.gz
mongodump --host "$UABIERTA_MONGODB_HOST" --username "$UABIERTA_MONGODB_USER" --password "$UABIERTA_MONGODB_PASSWORD" --authenticationDatabase "$UABIERTA_MONGODB_CONTENTSTORE" --archive --db $UABIERTA_MONGODB_COMMENT | gzip > $folder/mongodb_comment.gz

# Dump s3
mkdir -p /tmp/s3
aws --endpoint-url https://s3.uabierta.uchile.cl s3 cp s3://storeuabierta /tmp/s3/storeuabierta --recursive --quiet
aws --endpoint-url https://s3.uabierta.uchile.cl s3 cp s3://internaluabierta /tmp/s3/internaluabierta --recursive --quiet
tar -zcf $folder/s3.tar.gz /tmp/s3/
rm -rf /tmp/s3
