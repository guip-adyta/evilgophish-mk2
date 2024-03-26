# Build Golang binary
FROM golang:1.22 AS build-golang

WORKDIR /go/src/github.com/evilginx3/evilginx3
COPY . .
RUN go get -v && go build -v -o evilginx3

# Runtime container
FROM debian:stable-slim

RUN useradd -m -d /opt/evilginx3 -s /bin/bash app

RUN apt-get update && \
	apt-get install --no-install-recommends -y jq libcap2-bin && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/evilginx3
COPY --from=build-golang /go/src/github.com/evilginx3/evilginx3/ ./
COPY ./legacy_phishlets ./legacy_phishlets

USER app
EXPOSE 443 53

#CMD ["./docker/run.sh"]
#STOPSIGNAL SIGKILL

COPY ./entrypoint.sh /opt
ENTRYPOINT ["/opt/entrypoint.sh"]
STOPSIGNAL SIGKILL