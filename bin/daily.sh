#!/bin/bash
set -Exeo pipefail
cd "${HOME}"
uptime
date --utc

parallel --keep-order -vj0 {} <<-EOL
	  ssh ct8 "devil info account"
	  ssh serv00 "devil info account"
	  esperoj daily_archive
	  daily-backup.sh
	  esperoj daily_verify
EOL
