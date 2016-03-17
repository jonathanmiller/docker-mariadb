# MariaDB 10 (https://mariadb.org/)

FROM ubuntu:trusty
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
    echo 'mariadb-server-10.1 mysql-server/root_password password password1' | debconf-set-selections && \
    echo 'mariadb-server-10.1 mysql-server/root_password_again password password1' | debconf-set-selections && \
    apt-get -y install software-properties-common && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    add-apt-repository 'deb [arch=amd64,i386] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu trusty main' && \
    apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get install -y pwgen inotify-tools

# Decouple our data from our container.
# VOLUME ["/data"]
RUN mkdir /data && \
    chown -R mysql:mysql /data

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data/' /etc/mysql/my.cnf && \
    sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf

EXPOSE 3306
ADD scripts /scripts
RUN chmod +x /scripts/*.sh && \
    touch /firstrun

ENTRYPOINT ["/scripts/start.sh"]
