#!/bin/bash

set -Exeo pipefail
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/start"
cd "${HOME}"
start.sh esperoj_storage caddy
parallel --keep-order -vj0 {} <<EOL
  info.sh
  daily-backup.sh
  echo esperoj daily_verify
EOL
curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily/${?}"
stop.sh esperoj_storage caddy
