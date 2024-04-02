#!/bin/bash

echo "Apache2 runtime configuration:" && cat /etc/apache2/sites-enabled/000-default.conf
apache2ctl -D FOREGROUND