#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1:0:1}" = '-' ]; then
    set -- tarantool "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'tarantool' -a "$(id -u)" = '0' ]; then
    chown -R tarantool /var/lib/tarantool
    exec gosu tarantool "$0" "$@"
fi

# entry point wraps the passed script to do basic setup
if [ "$1" = 'tarantool' ]; then
    shift

    if [ "$1" = "/opt/tarantool/init.lua" ] && [ ! -f /opt/tarantool/init.lua ]; then
        exec tarantool /opt/cartridge-init/init.lua
    else
        exec tarantool "$@"
    fi
fi

exec "$@"
