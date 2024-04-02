# Minify client side assets (JavaScript)
FROM node:latest AS build-js

USER root
RUN npm install gulp gulp-cli -g
##-- Front-end
WORKDIR /build
COPY gophish/. .
RUN npm install --only=dev
RUN npm i gulp
##--

# Build Golang binary for Gophish
FROM golang:1.22 AS build-golang-gophish
WORKDIR /go/src/github.com/gophish/gophish
COPY gophish/. .
RUN go get -v && go build -v

# Build Golang binary for Evilginx3
FROM golang:1.22 AS build-golang-evilginx3
WORKDIR /go/src/github.com/evilginx3/evilginx3
COPY evilginx3/. .
RUN go get -v && go build -v -o evilginx3

# Runtime container
FROM debian:stable-slim AS runtime

RUN apt-get update && \
    apt-get install -y apache2 build-essential letsencrypt certbot wget git net-tools tmux openssl jq libcap2-bin sqlite3 && \
    a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests rewrite ssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

##-- gophish
WORKDIR /opt/gophish
COPY --from=build-golang-gophish /go/src/github.com/gophish/gophish/ ./
COPY --from=build-js /build/static/js/dist/ ./static/js/dist/
COPY --from=build-js /build/static/css/dist/ ./static/css/dist/
COPY --from=build-golang-gophish /go/src/github.com/gophish/gophish/config.json ./
COPY ./gophish/docker ./
RUN setcap 'cap_net_bind_service=+ep' /opt/gophish/gophish
RUN sed -i 's/127.0.0.1/0.0.0.0/g' config.json
RUN touch config.json.tmp
##--

##-- evilginx3
WORKDIR /opt/evilginx3
COPY --from=build-golang-evilginx3 /go/src/github.com/evilginx3/evilginx3/ ./
COPY ./evilginx3/legacy_phishlets ./legacy_phishlets
COPY ./evilginx3/conf ./conf
COPY ./evilginx3/run.sh ./
##--

##-- Apache2 Reverse Proxy
ENV EVILGINX3_SUBS=test.com \
    REDIRECT_URL=https://microsoft.com
WORKDIR /etc/apache2
COPY apache2/run.sh .
COPY apache2/fullchain.pem .
COPY apache2/privkey.pem .
COPY apache2/ports.conf .
COPY apache2/000-default-no-bl.conf.template ./sites-enabled/000-default.conf
COPY apache2/redirect.rules.template redirect.rules
RUN sed -i "s|Listen 80||g" ports.conf
RUN sed -i "s|https://en.wikipedia.org/|$REDIRECT_URL|g" redirect.rules
WORKDIR /etc/apache2/sites-enabled
RUN sed -i "s/ServerAlias evilginx3.template/ServerAlias $EVILGINX3_SUBS/g" 000-default.conf
## [!] Local Test
RUN sed -i "s|SSLCertificateFile|SSLCertificateFile /etc/apache2/fullchain.pem|g" 000-default.conf    
RUN sed -i "s|SSLCertificateKeyFile|SSLCertificateKeyFile /etc/apache2/privkey.pem|g" 000-default.conf
##--

WORKDIR /opt
COPY run_all.sh .
EXPOSE 3333 8080 8443 80 443 53
CMD ["/opt/run_all.sh"]