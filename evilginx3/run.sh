#!/bin/bash
#
# sleep 15
# Docker Compose -> -g /opt/db/gophish.db \
# Dockerfile -> -g /opt/gophish/db/gophish.db \
/opt/evilginx3/evilginx3 \
    -g /opt/gophish/db/gophish.db \
    -p /opt/evilginx3/legacy_phishlets \
    -c /opt/evilginx3/conf \
    -developer

tail -f /dev/null