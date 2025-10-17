FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y apt-transport-https wget lsb-release gnupg
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
RUN wget --quiet -O - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" >> /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://repo.mysql.com/apt/ubuntu bionic mysql-5.7" >> /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C
RUN apt-get update
RUN apt-get install -y \
    mongodb-database-tools \
    postgresql-client-13 \
    mysql-client=5.7* \
    nmap \
    unzip
RUN rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://downloads.rclone.org/v1.71.1/rclone-v1.71.1-linux-amd64.zip
RUN unzip rclone-v1.71.1-linux-amd64.zip
RUN cp rclone-v1.71.1-linux-amd64/rclone /usr/bin/rclone
RUN chmod 755 /usr/bin/rclone
RUN rm -rf rclone-v1.71.1-linux-amd64

# Platform name
ENV PLATFORM_NAME=""

# Postgresql server
ENV PLATFORM_POSTGRESQL_HOST=""
ENV PLATFORM_POSTGRESQL_PORT=""
ENV PLATFORM_POSTGRESQL_USER=""
ENV PGPASSWORD=""
ENV PLATFORM_POSTGRESQL_DATABASES="edxapp edxapp_csmh moodle"

# MySQL server
ENV PLATFORM_MYSQL_HOST=""
ENV PLATFORM_MYSQL_USER=""
ENV PLATFORM_MYSQL_PASSWORD=""
ENV PLATFORM_MYSQL_DATABASES="edxapp edxapp_csmh"

# MongoDB server
ENV PLATFORM_MONGODB_HOST=""
ENV PLATFORM_MONGODB_USER=""
ENV PLATFORM_MONGODB_PASSWORD=""

# S3 Server
ENV PLATFORM_S3_URL=""
ENV PLATFORM_S3_ACCESS_KEY=""
ENV PLATFORM_S3_SECRET_KEY=""
ENV PLATFORM_S3_BUCKETS=""

# GDrive
ENV PLATFORM_GRIVE_CLIENT_ID=""
ENV PLATFORM_GDRIVE_CLIENT_SECRET=""
ENV PLATFORM_GDRIVE_SCOPE=""
ENV PLATFORM_GDRIVE_TOKEN=""

# Moodle
ENV PLATFORM_MOODLE_DATA=""

# NAS
ENV NAS_HOST=""
ENV NAS_USER=""
ENV NAS_PASS=""
ENV NAS_KEY_FILE_PASS=""

# HOST FS
ENV HOST_MOUNT="/host_mount"

RUN mkdir -p /root/.config/rclone

ADD scripts /root/scripts
