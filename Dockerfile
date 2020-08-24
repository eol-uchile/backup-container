FROM ubuntu:16.04

RUN apt-get update && apt-get install -y apt-transport-https wget lsb-release && \
  wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb && \
  dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb && \
  rm percona-release_0.1-4.$(lsb_release -sc)_all.deb && \
  echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
  wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | apt-key add - && \
  apt-get update && \
  apt-get install -y \
    mongodb-org-tools \
    mysql-client \
    nmap \
    cron \
    python3-pip \
    percona-xtrabackup && \
  rm -rf /var/lib/apt/lists/* && \
  pip3 install awscli

ADD cron-root /var/spool/cron/crontabs/root
ADD scripts /root/scripts
VOLUME /root/env

CMD ["/usr/sbin/cron", "-f"]
