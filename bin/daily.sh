#!/bin/bash

curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
set -Eeuo pipefail
cd "${HOME}"
install.sh filen internet_archive
start.sh filen && sleep 3
start.sh esperoj_storage caddy
sleep 2
uv tool upgrade --all
parallel --keep-order -vj0 {} ::: \
  "time info.sh" \
  "time daily-backup.sh" \
  "time esperoj daily_verify" \
  "time rclone delete tmp: --min-age 7d --rmdirs"
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage filen caddy
