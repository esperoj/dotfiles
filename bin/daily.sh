#!/bin/bash

curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
set -Eeuo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} ::: \
  "install.sh filen && start.sh filen" \
  "uv tool upgrade --all"

start.sh esperoj_storage caddy
sleep 3
parallel --keep-order -vj0 {} ::: \
  "time daily-backup.sh" \
  "time info.sh" \
  "time esperoj daily_verify"
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage filen caddy
