#!/bin/sh

set -e

if [ ! -d /data/ssl ]; then
    echo "* initalizing certificate"    
    mkdir /data/ssl
    ./gencert.sh /data/ssl/
    openssl dhparam -dsaparam -out /data/ssl/dh4096.pem 4096
fi

while [ ! -f "/data/ssl/dh4096.pem" ]; do 
   sleep 2
done

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

    # set hostname as me
    hostname -f > /etc/haraka/config/me
    # link in certs
    ln -s /data/ssl/server.key /etc/haraka/config/tls_key.pem
    ln -s /data/ssl/server.crt /etc/haraka/config/tls_cert.pem

    if [ ! -f "/etc/haraka/configured" ]; then
        hostname -f > /etc/haraka/config/host_list

        sed -i -e "s/host*=.*/host=$MYSQL_HOST/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/user*=.*/host=$MYSQL_USER/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/password*=.*/host=$MYSQL_PASSWORD/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini
        sed -i -e "s/database*=.*/host=$MYSQL_DATABASE/g" /etc/haraka/config/auth_sql_cryptmd5.ini /etc/haraka/config/quota.check.ini /etc/haraka/config/aliases_mysql.ini

        touch /etc/haraka/configured
    fi
fi

exec "$@"