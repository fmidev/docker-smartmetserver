#!/bin/bash
set -e

if [ "$1" = 'smartmetd' ]; then
    exec /usr/sbin/smartmetd -c /etc/smartmet/conf/smartmet.conf
fi

exec "$@"
