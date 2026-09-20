#!/usr/bin/env bash

set -euo pipefail

if ! pgrep -f "Xvfb :99" >/dev/null; then
    rm -f /tmp/.X99-lock
    Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
fi

if [ "$#" -eq 0 ]; then
    set -- sleep infinity
fi

exec "$@"
