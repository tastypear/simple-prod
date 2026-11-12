#!/bin/sh
set -eu

: "${USER_PASS:?USER_PASS is required (format: user:password)}"

mkdir -p /data

if [ -n "${CLOUDFLARED_TOKEN:-}" ]; then
    ./cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" &
fi

./handy-sshd -u "$USER_PASS" &

exec ./ttyd -p "${PORT:-7681}" -c "$USER_PASS" -W bash
