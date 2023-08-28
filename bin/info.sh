#!/bin/bash

set -Eeuxo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
  echo "\${BUILD_DATE:-Today}"
  chezmoi status
  pwd
  curl -fLsS "https://ipwho.de"
  df -h
  free -h
  uptime
  inxi -ABCDEGIJLMNPRSWdfijlmnoprstuw
  rclone listremotes
  restic check
  python --version
  node --version
  ssh segfault "uname -a; lsb_release -a"
  ssh envs "uname -a; lsb_release -a"
  ssh serv00 "uname -a"
  ssh ct8 "uname -a"
EOL
