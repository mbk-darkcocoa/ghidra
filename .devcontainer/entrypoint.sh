#!/usr/bin/env bash

set -euo pipefail

flock /tmp/ghidra-xvfb.lock bash -lc '
    if ! pgrep -f "Xvfb :99" >/dev/null; then
        rm -f /tmp/.X99-lock
        Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
    fi
    for _ in $(seq 1 50); do
        if xdpyinfo -display :99 >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
'

if [ "$#" -eq 0 ]; then
    set -- sleep infinity
fi

exec "$@"
