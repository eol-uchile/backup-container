FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-transport-https wget lsb-release gnupg
RUN echo "deb [ arch=amd64, signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
RUN wget --quiet -O - https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
RUN echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg -o /usr/share/keyrings/postgresql.gpg --dearmor
RUN echo "deb http://repo.mysql.com/apt/ubuntu jammy mysql-8.4-lts" | tee /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C
RUN apt-get update
RUN apt-get install -y \
    mongodb-database-tools \
    postgresql-client-16 \
    mysql-client=8.4* \
    unzip
RUN rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://downloads.rclone.org/v1.70.3/rclone-v1.70.3-linux-amd64.zip
RUN unzip rclone-v1.70.3-linux-amd64.zip
RUN cp rclone-v1.70.3-linux-amd64/rclone /usr/bin/rclone
RUN chmod 755 /usr/bin/rclone
RUN rm -rf rclone-v1.70.3-linux-amd64
RUN rm -v rclone-v1.70.3-linux-amd64.zip

RUN mkdir -p /root/.config/rclone

ADD scripts /root/scripts
