#!/bin/bash

set -Eeuxo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
  7z
  chezmoi status
  curl -fLsS "https://ipwho.de"
  df -h
  free -h
  inxi -ABCDEGIJLMNPRSWdfijlmnoprstuw
  node --version
  pwd
  python --version
  rclone listremotes
  restic check
  ssh ct8 "uname -a"
  ssh envs "uname -a; lsb_release -a"
  ssh hashbang "uname -a; lsb_release -a"
  ssh segfault "uname -a; lsb_release -a"
  ssh serv00 "uname -a"
  uptime
EOL
