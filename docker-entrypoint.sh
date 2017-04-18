#!/bin/bash
set -e

if [ "$1" = 'smartmetd' ]; then
    exec /usr/sbin/smartmetd -d -v --logrequests
fi

exec "$@"
