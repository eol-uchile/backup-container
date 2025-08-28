#!/usr/bin/env bash

set -eu
input=${1}
output=${2}

openssl aes-256-cbc -md sha256 -salt -in ${input} -out ${output} -pass pass:"$BACKUP_PASSWORD"
rm -v ${input}
