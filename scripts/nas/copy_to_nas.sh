#!/usr/bin/env bash

#
# Cipher local backups and copy to public NAS
#

set -eu

apt update && apt install ssh-client sshpass

mkdir /ciphered

# Root folder as $PLATFORM_NAME/$option/
root_folder=$1
# Remote folder without ending /
remote_folder=$2

available_backups=$(ls $root_folder)

for sub_folder in $available_backups; do
  tar -zcf - $root_folder$sub_folder | openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -out /ciphered/$sub_folder.tar.gz.enc -pass pass:"$BACKUP_PASSWORD" || true
  sshpass -p '$NAS_PASSWORD' scp /ciphered/$sub_folder.tar.gz.enc $NAS_USER@$NAS_IP:$remote_folder/$root_folder/
done

# To decipher
# openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -salt -in file_with_tar_gz_enc -out file_with_tar_gz -pass pass:"$BACKUP_PASSWORD" -d
# tar -zxvf file_with_tar_gz -C out_folder
