#!/bin/bash

curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
set -Eeuo pipefail
cd "${HOME}"
install.sh filen
start.sh filen && sleep 3
start.sh esperoj_storage caddy
sleep 2
parallel --keep-order -vj0 {} ::: \
  "time info.sh" \
  "time daily-backup.sh" \
  "time esperoj daily_verify"
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage filen caddy
