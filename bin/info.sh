#!/bin/bash

set -Eexo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
	  chezmoi status
	  curl -sS https://ipwho.de
	  df -hT
	  free -h
	  lsblk
	  lscpu
	  pwd
	  python3 --version
	  rclone listremotes
	  ssh ct8 "uptime"
	  ssh envs "uptime"
	  ssh hashbang "uptime"
	  ssh serv00 "uptime"
	  ssh tteam "uptime"
	  ssh ttown "uptime"
	  uptime
EOL
