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
  tar -cf - $root_folder$sub_folder | openssl aes-256-cbc -md sha256 -salt -out /ciphered/$sub_folder.tar.enc -pass pass:"$BACKUP_PASSWORD" || true
  sshpass -p '$NAS_PASSWORD' scp /ciphered/$sub_folder.tar.enc $NAS_USER@$NAS_IP:$remote_folder/$root_folder/
done

# To unchiper
# openssl enc -d -aes-256-cbc -in file_with_tar_enc -out file_with_tar -pass pass:"$BACKUP_PASSWORD"
# tar -xvf file_with_tar -C out_folder