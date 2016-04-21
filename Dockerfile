FROM alpine:latest

RUN \
	apk add --no-cache \
		nodejs \
	&& apk add --no-cache --virtual .build-deps \
		make \
        g++ \
        python \		
	&& npm install -g Haraka@2.7.3 mkdirp mysql \
	&& haraka -i /etc/haraka \
	&& apk del .build-deps \
	&& mkdir /data \
	&& mkdir /etc/haraka/queue \
	&& chown mail:mail -R /data/ /etc/haraka/queue/	

COPY ./haraka /etc/haraka

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

VOLUME ["/data"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-c", "/etc/haraka"]