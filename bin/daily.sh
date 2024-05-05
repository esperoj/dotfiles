#!/bin/bash

set -Exeo pipefail
cd "${HOME}"
uptime
date --utc

parallel --keep-order -vj0 {} <<-EOL
  ssh alwaysdata "~/.local/bin/chezmoi update --force --no-tty"
  ssh ct8 "devil info account"
  ssh serv00 "devil info account"
  daily-backup.sh
  esperoj daily_archive
  esperoj daily_verify
EOL
