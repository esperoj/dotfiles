#!/bin/bash

set -Exeo pipefail
cd "${HOME}"
uptime
date --utc
start.sh pcloud caddy
# TODO: Keep the two pcloud accounts alive

parallel --keep-order -vj0 {} <<EOL
  ssh ct8 "uptime"
  ssh serv00 "uptime"
  ssh segfault "uptime"
  time daily-backup.sh
  esperoj daily_verify
EOL

stop.sh pcloud caddy
sleep 1
