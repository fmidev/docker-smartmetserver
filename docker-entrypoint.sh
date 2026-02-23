#!/bin/bash
set -e

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [ "$1" = 'smartmetd' ]; then
    id
    whoami
    LD_PRELOAD=libjemalloc.so.2 exec /usr/sbin/smartmetd
fi

exec "$@"
