#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# INSTALL MYSQL 5.6
# (https://github.com/piwik/piwik/commit/20bd2e1c24e5d673dce3feb256204ad48c29f160)
# TODO: Remove when mysql 5.6 is provided by travis.
# Otherwise, our migrations will raise a syntax error.
sudo /etc/init.d/mysql stop
sudo apt-get remove mysql-common mysql-server-5.5 mysql-server-core-5.5 mysql-client-5.5 mysql-client-core-5.5


MYSQL_MAJOR=5.6

sudo apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5
sudo bash -c "echo 'deb http://repo.mysql.com/apt/ubuntu/ precise mysql-$MYSQL_MAJOR' > /etc/apt/sources.list.d/mysql.list"
sudo apt-get update
sudo apt-get install -y --force-yes \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    mysql-server-5.6 libaio1 libevent-dev

# wget -O mysql-5.6.14.deb http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.14-debian6.0-x86_64.deb/from/http://cdn.mysql.com/
# sudo dpkg -i mysql-5.6.14.deb
# sudo apt-get update
# sudo apt-get install libaio1 libevent-dev

sudo cp /opt/mysql/server-5.6/support-files/mysql.server /etc/init.d/mysql.server
sudo ln -s /opt/mysql/server-5.6/bin/* /usr/bin/
sudo sed -i'' 's/table_cache/table_open_cache/' /etc/mysql/my.cnf
sudo sed -i'' 's/log_slow_queries/slow_query_log/' /etc/mysql/my.cnf
sudo sed -i'' 's/basedir[^=]\+=.*$/basedir = \/opt\/mysql\/server-5.6/' /etc/mysql/my.cnf
sudo /etc/init.d/mysql.server start
sudo mysql_upgrade -u root --force
echo "my.cfg"
sudo bash -c 'echo "plugin-load = daemon_memcached=libmemcached.so" >> /etc/mysql/my.cnf'
cat /etc/mysql/my.cnf
mysql --version
sudo mysql -u root -e "SELECT VERSION();"
sudo cat /var/log/syslog | grep mysql

sudo mysql -u root -e "CREATE DATABASE test;"
sudo mysql -u root -e "source /opt/mysql/server-5.6/share/innodb_memcached_config.sql"
sudo mysql -u root -e 'INSTALL PLUGIN daemon_memcached soname "libmemcached.so";'
sudo /etc/init.d/mysql.server restart

echo "Listening ports:"
sudo lsof -nP -i | grep LISTEN
