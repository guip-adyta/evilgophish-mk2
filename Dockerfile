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
RUN go get -v && go mod vendor
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

WORKDIR /opt
COPY run_all.sh .
EXPOSE 3333 8080 8443 80 443 53
CMD ["/opt/run_all.sh"]


## Notes
# ---
# docker compose down
#1. docker compose up --build -d 
#2. docker attach evilgophish-mk2-evilginx3-1 
# ---
# ping gophish
# docker exec -it evilgophish-mk2-apache2-1 /bin/bash
# cat /var/log/apache2/error.log
# ---
# docker exec -it evilgophish-mk2-evilginx3-1 /bin/bash
# apt update && apt install -y dnsutils vim curl
# curl -H 'Host: sub.localtest.com' https://example.sub.localtest.com/login
# vi /etc/resolv.conf >>> nameserver 1.1.1.1
# vi /etc/hosts
# ---
# lsof -i :53
# nslookup login.example.sub.localtest.com