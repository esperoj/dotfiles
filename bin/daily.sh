#!/bin/bash

set -Exeo pipefail
cd "${HOME}"

start.sh koofr caddy
parallel --keep-order -vj0 {} <<EOL
  info.sh
  daily-backup.sh
  esperoj daily_verify
EOL
stop.sh koofr caddy
