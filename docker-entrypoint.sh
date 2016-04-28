#!/bin/sh

set -e

if [ ! -d /data/ssl ]; then
    echo "* initalizing certificate"    
    mkdir /data/ssl
    ./gencert.sh /data/ssl/
fi

for i in 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0; do
    if [ -f "/data/ssl/dh4096.pem" ]; then 
        break
    fi
    sleep 1
done
if [ "$i" = 0 ]; then
    echo >&2 'Certificate init process failed.'
    exit 1
fi

# if command starts with an option, prepend dovecot
if [ "${1:0:1}" = '-' ]; then
    set -- haraka "$@"
fi

if [ "$1" = 'haraka' ]; then
    # Get config

    if [ -z "$MYSQL_HOST" -o -z "$MYSQL_USER" -o -z "$MYSQL_DATABASE" ]; then
        echo mysql arugments required
        exit 1
    fi

    # set hostname for dovecot ehlo
    if [ ! -z "$HOSTNAME" ]; then
        echo $HOSTNAME > > /etc/haraka/config/me
    else
        hostname -f > /etc/haraka/config/me
    fi

    # link in certs
    rm /etc/haraka/config/tls_cert.pem /etc/haraka/config/tls_key.pem
    ln -s /data/ssl/server.key /etc/haraka/config/tls_key.pem 2> /dev/null
    ln -s /data/ssl/server.crt /etc/haraka/config/tls_cert.pem 2> /dev/null

    if [ ! -f "/etc/haraka/configured" ]; then
        # create database tables
        mkdir /tmp/db
        cp createdb.js /tmp/db
        cp database.sql /tmp/db
        cd /tmp/db
        npm install mysql
        node createdb.js
        rm -rf /tmp/db

        sed -i -e "s/host*=.*/host=$MYSQL_HOST/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/user*=.*/user=$MYSQL_USER/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/password*=.*/password=$MYSQL_PASSWORD/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/database*=.*/database=$MYSQL_DATABASE/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini

        touch /etc/haraka/configured
    fi
fi

exec "$@"