# MariaDB 10 (https://mariadb.org/)

FROM ubuntu:precise
MAINTAINER Jonathan Miller <jonathan.michael.miller@gmail.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('');"

# Install MariaDB from repository.
RUN DEBIAN_FRONTEND=noninteractive && \
    debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password password password1' && \
    debconf-set-selections <<< 'mariadb-server-10.0 mysql-server/root_password_again password password1' && \
    apt-get -y install python-software-properties && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb http://mirror.jmu.edu/pub/mariadb/repo/10.0/ubuntu precise main' && \
    apt-get update && \
    apt-get install -y mariadb-server

# RUN apt-get -y install curl && \
#     mkdir /scripts && \
#     curl https://raw.githubusercontent.com/jonathanmiller/docker-mariadb/master/scripts/first_run.sh > /scripts/first_run.sh && \
#     curl https://raw.githubusercontent.com/jonathanmiller/docker-mariadb/master/scripts/start.sh > /scripts/start.sh && \
#     curl https://raw.githubusercontent.com/jonathanmiller/docker-mariadb/master/scripts/normal_run.sh > /scripts/normal_run.sh && \
#     chmod +x /scripts/*.sh

# Install other tools.
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y pwgen inotify-tools

# Decouple our data from our container.
# VOLUME ["/data"]
RUN mkdir /data

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

EXPOSE 3306
ADD scripts /scripts
RUN chmod +x /scripts/start.sh
RUN touch /firstrun

ENTRYPOINT ["/scripts/start.sh"]
