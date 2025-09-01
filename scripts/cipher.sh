#!/usr/bin/env bash

set -eu
input=${1}
output=${2}

openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in ${input} -out ${output} -pass pass:"$BACKUP_PASSWORD"
rm -v ${input}
