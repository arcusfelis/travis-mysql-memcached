#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
MYSQL_MAJOR=5.6

sudo /etc/init.d/mysql stop
sudo apt-get remove mysql-common mysql-server-5.5 mysql-server-core-5.5 mysql-client-5.5 mysql-client-core-5.5

sudo apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5
sudo bash -c "echo 'deb http://repo.mysql.com/apt/ubuntu/ precise mysql-$MYSQL_MAJOR' > /etc/apt/sources.list.d/mysql.list"
sudo apt-get update
sudo apt-get install -y --force-yes \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    mysql-server-$MYSQL_MAJOR libaio1 libevent-dev

sudo sed -i \
    -e 's/table_cache/table_open_cache/' \
    -e 's/log_slow_queries/slow_query_log/' /etc/mysql/my.cnf
sudo /etc/init.d/mysql start
sudo mysql_upgrade -u root --force

sudo mysql -u root -e 'CREATE DATABASE test;
    SOURCE /usr/share/mysql/innodb_memcached_config.sql;
    INSTALL PLUGIN daemon_memcached soname "libmemcached.so";'
sudo /etc/init.d/mysql restart

echo "Listening ports:"
sudo lsof -nP -i | grep LISTEN
