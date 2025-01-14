#!/bin/bash

curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
set -Eeuo pipefail
cd "${HOME}"
install.sh filen
start.sh esperoj_storage filen caddy
parallel --keep-order -vj0 {} <<EOL
  command time -v info.sh
  command time -v daily-backup.sh
  echo esperoj daily_verify
  echo esperoj save_page "https://esperoj.eu.org/print.html"
  echo esperoj save_page "https://esperoj.vercel.app"
EOL
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage filen caddy
