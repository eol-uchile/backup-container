# Backup Container

Backup databases to remote locations such as S3 and Drive

The *backup.sh* script receives one argument and should be set either to **daily** or **hourly**. This allows us to reuse it. The backup configures rclone and then downloads the remote content from each service.

Each new service added should do the following steps:
* Unpack the arguments folder and remote_folder
* Dump the service for recovery
* Use rclone to send the data upstream
* Clean the local folder
If the service is optional it should check that the env vars are set.