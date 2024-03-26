#!/bin/bash
#
# /opt/gophish/gophish.db
# sleep 15
/opt/evilginx3/evilginx3 \
    -g /opt/db/gophish.db \
    -p /opt/evilginx3/legacy_phishlets \
    -c /opt/evilginx3/conf \
    -developer

tail -f /dev/null