FROM ubuntu:latest

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    build-essential \
    wget \
    git \
    net-tools \
    tmux \
    openssl \
    jq \
    curl \
 && rm -rf /var/lib/apt/lists/*

# ARCH: amd64
RUN GO_VERSION=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version' | sed 's/go//') && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    ln -sf /usr/local/go/bin/go /usr/bin/go && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

ENV GOPATH=/go \
    PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

COPY . /root

# TODO
# 1. Build services
# 2. evilfeed
RUN cd /root/gophish && go build && \
    cd /root/evilginx && go build

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

EXPOSE 80 443 3333 53/udp 53/tcp

CMD ["/startup.sh"]
