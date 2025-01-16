#!/bin/bash

curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
set -Eeuo pipefail
cd "${HOME}"
install.sh filen
start.sh esperoj_storage filen caddy
parallel --keep-order -vj0 command time -v {} ::: \
  "info.sh" \
  "daily-backup.sh" \
  "esperoj daily_verify"
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage filen caddy
