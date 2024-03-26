#!/bin/bash
#
# /opt/gophish/gophish.db
/opt/evilginx3/evilginx3 \
    -g /opt/gophish/gophish.db \ 
    -p /opt/evilginx3/legacy_phishlets \
    -developer 
#    -c /config/evilginx \
#    -developer