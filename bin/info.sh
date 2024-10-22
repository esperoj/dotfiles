#!/bin/bash

set -Eexo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
  chezmoi status
  curl -sS https://ipwho.de
  df -hT
  echo esperoj --help
  free -h
  pwd
  python3 --version
  rclone listremotes
  ssh ct8 "uptime"
  ssh envs "uptime"
  ssh hashbang "uptime"
  ssh serv00 "uptime"
  uptime
EOL
