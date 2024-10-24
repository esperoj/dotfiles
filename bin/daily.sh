#!/bin/bash

set -Eeo pipefail
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
cd "${HOME}"
start.sh esperoj_storage caddy
parallel --keep-order -vj0 {} <<EOL
  info.sh
  daily-backup.sh
  echo esperoj daily_verify
  echo esperoj save_page "https://esperoj.eu.org/print.html"
  echo esperoj save_page "https://esperoj.vercel.app"
EOL
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage caddy
