# Backup Container

Backup databases to remote locations such as S3 and Drive

The *backup.sh* script receives two arguments:
* first either to **daily** or **hourly**.
* The name of the scripts to load or backups to run.
The backup configures rclone and then downloads the remote content from each service.

Each new service added should do the following steps:
* Unpack the arguments folder and remote_folder
* Dump the service for recovery
* Use rclone to send the data upstream
* Clean the local folder
If the service is optional it should check that the env vars are set.

## Additional Scripts

* *backup_local.sh < hourly,daily>\* < out_folder>\* < date in YYYY-MM-DD format> < days>* Copies the remote backups from daily (all 24) or x number of days from a given date.
* *copy_to_nas.sh* Assumes that the env vars NAS_USER NAS_IP and NAS_PASSWORD are defined. i.e. 
```bash
$ ./copy_to_nas.sh $PLATFORM_NAME/$option/ folder_on_nas
```
* *restore.sh* Script for platform recovery using either local or remote backups. (ES Indexes are not updated from this processes)

## Notes

Two images exist to accomodate the different versions of Elastic Search and MongoDB since the API is not compatible for backup restoration between versions.