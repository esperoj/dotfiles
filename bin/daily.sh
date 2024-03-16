#!/bin/bash
set -Exeo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
	  ssh ct8 "devil info account"
	  ssh serv00 "devil info account"
	  esperoj daily_verify
	  esperoj daily_archive
EOL
