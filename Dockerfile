FROM alpine:latest

RUN \
    apk add --no-cache \
        nodejs \
        openssl \
    && apk add --no-cache --virtual .build-deps \
        make \
        g++ \
        python \
    && npm install -g Haraka@2.7.3 mysql \
    && haraka -i /etc/haraka \
    && apk del .build-deps \
    && mkdir /data \
    && mkdir /etc/haraka/queue \
    && chown mail:mail -R /data/ /etc/haraka/queue/ 

COPY ./haraka /etc/haraka

COPY ./gencert.sh ./docker-entrypoint.sh ./createdb.js ./database.sql /

RUN chmod +x /docker-entrypoint.sh /gencert.sh

VOLUME ["/data"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-c", "/etc/haraka"]