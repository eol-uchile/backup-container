FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-transport-https wget lsb-release gnupg
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list
RUN wget --quiet -O - https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" >> /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://repo.mysql.com/apt/ubuntu jammy mysql-8.4-lts" >> /etc/apt/sources.list.d/mysql.list
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys B7B3B788A8D3785C
RUN apt-get update
RUN apt-get install -y \
    mongodb-database-tools \
    postgresql-client-14 \
    mysql-client=8.4* \
    nmap \
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
