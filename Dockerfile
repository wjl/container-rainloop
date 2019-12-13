FROM alpine

# Install Apache & PHP
RUN \
	apk update && \
	apk upgrade && \
	apk add --no-cache \
		apache2 \
		php7 \
		php7-apache2 \
		php7-curl \
		php7-dom \
		php7-iconv \
		php7-json \
		php7-openssl \
		php7-pdo_sqlite \
	&& \
	rm -r /var/cache/apk/* && \
	true

# Fix up Apache configuration.
COPY httpd.conf.patch /tmp
RUN \
	cd /etc/apache2 && \
	patch < /tmp/httpd.conf.patch && \
	true

# Make logs to stdout & stderr.
RUN \
	ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/stderr /var/log/apache2/error.log && \
	true

# Install Rainloop into web root.
RUN \
	cd /var/www/localhost/htdocs && \
	rm index.html && \
	wget -qO- https://repository.rainloop.net/installer.php | php && \
	printf '%s\n' "Deny from all" > data/.htaccess && \
	true

ENTRYPOINT ["/usr/sbin/httpd", "-DFOREGROUND"]

HEALTHCHECK --interval=30m --timeout=10s \
  CMD wget --spider http://localhost:80/

# Expose http port.
EXPOSE 80/tcp

# Rainloop data directory.
VOLUME /var/www/localhost/htdocs/data
