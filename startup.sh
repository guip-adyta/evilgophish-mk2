#!/bin/bash

cd /root/gophish
./gophish &

while [ ! -f ./gophish.db ]; do
  sleep 1
done

cd /root/evilginx
./evilginx -g ../gophish/gophish.db -p legacy_phishlets -c ../conf/evilginx -developer &

wait
